import React from "react"
import { Outlet, useLocation, useNavigate } from "react-router-dom"
import { useAuth, useSignOut } from "../auth_context"

const itemsFor = (role) => {
  if (role === "human_resource") {
    return [["/", "Home"], ["/employees", "Employees"], ["/departments", "Departments"], ["/locations", "Locations"]]
  }
  if (role === "company_admin") {
    return [["/", "Home"], ["/employees", "Employees"], ["/departments", "Departments"], ["/locations", "Locations"]]
  }
  return [["/me", "My profile"]]
}

export default function Layout() {
  const { user } = useAuth()
  const signOut = useSignOut()
  const navigate = useNavigate()
  const location = useLocation()

  return (
    <div className="min-h-screen">
      <header className="fixed inset-x-0 top-0 z-20 flex h-16 items-center justify-between bg-ink px-6 text-white shadow-lg">
        <p className="text-lg font-semibold tracking-tight">{user?.company?.name || "Compensation"}</p>
        <div className="flex items-center gap-4 text-sm">
          <span className="hidden sm:inline">{user?.email}</span>
          <button type="button" className="btn border border-white/30 bg-white/10 hover:bg-white/20" onClick={signOut}>Sign out</button>
        </div>
      </header>
      <aside className="fixed bottom-0 left-0 top-16 w-60 border-r border-ink/10 bg-white/80 p-3 backdrop-blur">
        <nav className="space-y-1">
          {itemsFor(user?.role).map(([path, label]) => (
            <button
              key={path}
              type="button"
              onClick={() => navigate(path)}
              className={`w-full rounded-xl px-3 py-2 text-left text-sm font-medium transition hover:translate-x-0.5 hover:bg-teal-50 ${location.pathname === path ? "bg-teal-100 text-ink" : "text-stone-700"}`}
            >
              {label}
            </button>
          ))}
        </nav>
      </aside>
      <main className="ml-60 min-h-screen px-6 pb-10 pt-24 animate-fadeUp">
        <Outlet />
      </main>
    </div>
  )
}
