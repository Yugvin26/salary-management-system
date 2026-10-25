import React, { useEffect, useState } from "react"
import { api } from "../api_client"
import { ErrorBanner, SalaryHistoryTable } from "../ui_helpers"
import MonthlyPayout from "./MonthlyPayout"

export default function SelfProfile() {
  const [profile, setProfile] = useState(null)
  const [error, setError] = useState("")

  useEffect(() => {
    api("/api/profile").then((payload) => setProfile(payload.data)).catch((err) => setError(err.message))
  }, [])

  if (error) return <ErrorBanner message={error} />
  if (!profile) return <div className="card h-48 animate-pulse bg-stone-100" />

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-semibold text-ink">{profile.name}</h1>
      <div className="text-sm text-stone-700">
        <p>{profile.email}</p>
        <p>Employee ID {profile.employee_id}</p>
        <p>Job title {profile.job_title}</p>
        <p>Job type {profile.work_mode ? profile.work_mode.replace("_", " ") : "—"}</p>
        <p>Department {profile.department?.name}</p>
        <p>Location {profile.location?.name}, {profile.location?.country} · Hired {profile.hire_date}</p>
      </div>
      <p className="rounded-xl bg-sky-50 px-4 py-3 text-sm text-sky-900">Your salary history is read-only.</p>
      <MonthlyPayout payout={profile.monthly_payout} />
      <div className="card overflow-hidden">
        <SalaryHistoryTable salaries={profile.salaries || []} statusLabel="Status" />
      </div>
    </div>
  )
}
