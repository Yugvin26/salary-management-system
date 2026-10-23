import React from "react"
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom"
import { AuthProvider, useAuth } from "./auth_context"
import Login from "./components/Login"
import Layout from "./components/Layout"

function RequireRole({ children }) {
  const { user, ready } = useAuth()
  if (!ready) return <div className="p-8 text-sm text-stone-500">Loading session…</div>
  if (!user) return <Navigate to="/login" replace />
  return children
}

function Home() {
  const { user } = useAuth()
  if (!user) return <Navigate to="/login" replace />
  return <div className="card p-6 text-sm text-stone-600">Signed in as {user.email}</div>
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<RequireRole><Layout /></RequireRole>}>
            <Route path="/" element={<Home />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}
