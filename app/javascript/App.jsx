import React from "react"
import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom"
import { AuthProvider, useAuth } from "./auth_context"
import Login from "./components/Login"
import Layout from "./components/Layout"
import Dashboard from "./components/Dashboard"
import EmployeeList from "./components/EmployeeList"
import EmployeeForm from "./components/EmployeeForm"
import EmployeeDetail from "./components/EmployeeDetail"
import Departments from "./components/Departments"
import Locations from "./components/Locations"
import Reports from "./components/Reports"
import SelfProfile from "./components/SelfProfile"

const STAFF_ROLES = ["human_resource", "company_admin"]

function RequireRole({ children, allow, onDeny = "home" }) {
  const { user, ready } = useAuth()
  if (!ready) return <div className="p-8 text-sm text-stone-500">Loading session…</div>
  if (!user) return <Navigate to="/login" replace />
  if (allow && !allow.includes(user.role)) {
    if (onDeny === "staff") {
      if (user.role === "super_admin") return <Navigate to="/site-admin" replace />
      return <Navigate to={user.role === "employee" ? "/me" : "/"} replace />
    }
    return <Navigate to="/" replace />
  }
  if (!allow && user.role === "super_admin") return <Navigate to="/site-admin" replace />
  return children
}

function Home() {
  const { user } = useAuth()
  if (!user) return <Navigate to="/login" replace />
  if (user.role === "super_admin") return <Navigate to="/site-admin" replace />
  return user.role === "employee" ? <Navigate to="/me" replace /> : <Dashboard />
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />

          <Route element={<RequireRole><Layout /></RequireRole>}>
            <Route path="/" element={<Home />} />
            <Route path="/employees" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><EmployeeList /></RequireRole>} />
            <Route path="/employees/new" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><EmployeeForm /></RequireRole>} />
            <Route path="/employees/:id" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><EmployeeDetail /></RequireRole>} />
            <Route path="/employees/:id/edit" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><EmployeeForm /></RequireRole>} />
            <Route path="/departments" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><Departments /></RequireRole>} />
            <Route path="/locations" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><Locations /></RequireRole>} />
            <Route path="/reports" element={<RequireRole allow={STAFF_ROLES} onDeny="staff"><Reports /></RequireRole>} />
            <Route path="/me" element={<SelfProfile />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}
