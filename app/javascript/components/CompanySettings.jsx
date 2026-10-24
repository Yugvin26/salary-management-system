import React, { useEffect, useState } from "react"
import { api, errorMessage } from "../api_client"
import { applyCompanyTheme, useAuth } from "../auth_context"
import { ErrorBanner } from "../ui_helpers"

const fields = [
  ["primary_color", "Primary"],
  ["accent_color", "Accent"],
  ["background_color", "Background"]
]

export default function CompanySettings() {
  const { user, setUser } = useAuth()
  const [form, setForm] = useState({ primary_color: "#0f3d4c", accent_color: "#b8612d", background_color: "#f4f1ea" })
  const [error, setError] = useState("")
  const [saved, setSaved] = useState(false)

  useEffect(() => {
    api("/api/company_setting").then((payload) => setForm(payload.data)).catch(() => {})
  }, [])

  async function save(event) {
    event.preventDefault()
    setError("")
    setSaved(false)
    try {
      const payload = await api("/api/company_setting", { method: "PATCH", body: { setting: form } })
      setForm(payload.data)
      applyCompanyTheme(payload.data)
      setUser({ ...user, company: { ...user.company, setting: payload.data } })
      setSaved(true)
    } catch (err) {
      setError(errorMessage(err.payload))
    }
  }

  return (
    <form onSubmit={save} className="card mx-auto w-full max-w-xl space-y-4 p-6">
      <h1 className="text-3xl font-semibold text-ink">Company theme</h1>
      <p className="text-sm text-stone-600">These colours apply to every page your company can open, including reports and the dashboard.</p>
      <ErrorBanner message={error} />
      {saved && <p className="rounded-lg bg-emerald-50 px-3 py-2 text-sm text-emerald-800">Theme saved.</p>}
      {fields.map(([key, label]) => (
        <label key={key} className="block text-sm font-medium">{label}
          <input className="field mt-1 h-12" type="color" value={form[key]} onChange={(event) => setForm({ ...form, [key]: event.target.value })} />
        </label>
      ))}
      <button className="btn-primary" type="submit">Save theme</button>
    </form>
  )
}
