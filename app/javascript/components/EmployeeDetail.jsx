import React, { useEffect, useState } from "react"
import { useNavigate, useParams } from "react-router-dom"
import { api, errorMessage } from "../api_client"
import { useAuth } from "../auth_context"
import { ErrorBanner, Pager, rowClass, SalaryHistoryTable, salaryLabel } from "../ui_helpers"
import MonthlyPayout from "./MonthlyPayout"

function employeeFacts(employee) {
  const jobType = employee.work_mode
    ? employee.work_mode.split("_").map((word) => word.charAt(0).toUpperCase() + word.slice(1)).join(" ")
    : "—"
  const place = [employee.location?.name, [employee.location?.city, employee.location?.country].filter(Boolean).join(", ")]
    .filter(Boolean)
    .join(" · ")
  return [
    { label: "Employee ID", value: employee.employee_id || "—" },
    { label: "Job title", value: employee.job_title || "—" },
    { label: "Job type", value: jobType },
    { label: "Department", value: employee.department?.name || "—" },
    { label: "Location", value: place || "—" },
    { label: "Hire date", value: employee.hire_date || "—" }
  ]
}

export default function EmployeeDetail() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { user } = useAuth()
  const [employee, setEmployee] = useState(null)
  const ownProfile = user && employee && String(user.id) === String(employee.id)
  const [salaries, setSalaries] = useState([])
  const [salaryMeta, setSalaryMeta] = useState({ page: 1, per_page: 25, total: 0 })
  const [versions, setVersions] = useState([])
  const [versionMeta, setVersionMeta] = useState({ page: 1, per_page: 25, total: 0 })
  const [selectedSalary, setSelectedSalary] = useState(null)
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(true)
  const [form, setForm] = useState({ amount: "", currency: "USD", salary_type: "base", effective_on: "", current: true })
  const locationCurrency = {
    "United States": "USD",
    "United Kingdom": "GBP",
    Germany: "EUR",
    India: "INR",
    Brazil: "BRL"
  }

  function load(page = 1) {
    setLoading(true)
    Promise.all([
      api(`/api/employees/${id}`),
      api(`/api/employees/${id}/salaries?page=${page}&per_page=25`)
    ]).then(([employeePayload, salaryPayload]) => {
      setEmployee(employeePayload.data)
      setSalaries(salaryPayload.data)
      setSalaryMeta(salaryPayload.meta)
    }).finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [id])

  useEffect(() => {
    if (salaries.length > 0) {
      setForm((current) => ({ ...current, currency: salaries[0].currency }))
    } else if (employee?.location?.country) {
      const defaultCurrency = locationCurrency[employee.location.country] || "USD"
      setForm((current) => ({ ...current, currency: defaultCurrency }))
    }
  }, [employee, salaries])

  async function archive() {
    await api(`/api/employees/${id}/archive`, { method: "POST", body: {} })
    load()
  }

  async function unarchive() {
    await api(`/api/employees/${id}/unarchive`, { method: "POST", body: {} })
    load()
  }

  async function addSalary(event) {
    event.preventDefault()
    setError("")
    try {
      await api(`/api/employees/${id}/salaries`, { method: "POST", body: { salary: form } })
      setForm({ ...form, amount: "" })
      load()
    } catch (err) {
      setError(errorMessage(err.payload))
    }
  }

  async function openVersions(salaryId, page = 1) {
    const payload = await api(`/api/salaries/${salaryId}/versions?page=${page}&per_page=25`)
    setSelectedSalary(salaryId)
    setVersions(payload.data)
    setVersionMeta(payload.meta)
  }

  if (!employee || loading) {
    return (
      <div className="card space-y-3 p-6">
        <div className="h-8 w-1/2 animate-pulse rounded bg-stone-200" />
        <div className="h-4 w-2/3 animate-pulse rounded bg-stone-200" />
        <div className="h-40 animate-pulse rounded bg-stone-100" />
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex flex-wrap items-center gap-3">
            <h1 className="text-3xl font-semibold text-ink">{employee.name}</h1>
            <span className={`inline-flex rounded-full px-2.5 py-0.5 text-xs font-semibold ${employee.active ? "bg-emerald-100 text-emerald-800" : "bg-amber-100 text-amber-800"}`}>
              {employee.active ? "Active" : "Archived"}
            </span>
          </div>
          <p className="mt-1 text-sm text-stone-600">{employee.email}</p>
        </div>
        <div className="flex gap-2">
          <button type="button" className="btn-outline" onClick={() => navigate(`/employees/${id}/edit`)}>Edit</button>
          {employee.active && <button type="button" className="btn border border-amber-300 bg-white text-amber-800 hover:bg-amber-50" onClick={archive}>Archive</button>}
          {!employee.active && <button type="button" className="btn border border-emerald-300 bg-white text-emerald-800 hover:bg-emerald-50" onClick={unarchive}>Unarchive</button>}
        </div>
      </div>
      <dl className="card grid gap-px overflow-hidden bg-stone-200/70 sm:grid-cols-2 lg:grid-cols-3">
        {employeeFacts(employee).map((fact) => (
          <div key={fact.label} className="bg-white/95 px-4 py-3">
            <dt className="text-xs font-semibold uppercase tracking-wide text-stone-500">{fact.label}</dt>
            <dd className="mt-1 break-words text-sm font-medium text-ink">{fact.value}</dd>
          </div>
        ))}
      </dl>

      <MonthlyPayout payout={salaryMeta.monthly_payout} />

      <h2 className="text-xl font-semibold text-ink">Salary history</h2>
      <div className="card overflow-hidden">
        <SalaryHistoryTable
          salaries={salaries}
          action={(salary) => <button type="button" className="btn-outline px-2.5 py-1 text-xs" onClick={() => openVersions(salary.id)}>Versions</button>}
        />
        <Pager page={salaryMeta.page || 1} perPage={salaryMeta.per_page || 25} total={salaryMeta.total || 0} onPage={load} />
      </div>

      <h2 className="text-lg font-semibold text-ink">Add salary line</h2>
      {ownProfile ? (
        <p className="rounded-lg bg-amber-50 px-3 py-2 text-sm text-amber-900">You cannot change your own salary. Another HR user or a company admin can add it.</p>
      ) : (
      <>
      <ErrorBanner message={error} />
      <form onSubmit={addSalary} className="flex flex-wrap items-end gap-3">
        <label className="text-sm font-medium">Amount
          <input className="field mt-1" required value={form.amount} onChange={(event) => setForm({ ...form, amount: event.target.value })} />
        </label>
        <label className="text-sm font-medium" title="Currency stays fixed after the first salary line">Currency
          <input className="field mt-1 bg-stone-100" required value={form.currency} disabled />
        </label>
        <label className="text-sm font-medium">Type
          <select className="field mt-1" value={form.salary_type} onChange={(event) => setForm({ ...form, salary_type: event.target.value })}>
            <option value="base">base</option>
            <option value="bonus">bonus</option>
            <option value="commission">commission</option>
          </select>
        </label>
        <label className="text-sm font-medium">Effective date
          <input className="field mt-1" type="date" required value={form.effective_on} onChange={(event) => setForm({ ...form, effective_on: event.target.value })} />
        </label>
        <button className="btn-primary" type="submit">Add</button>
        <p className="w-full text-sm text-stone-600">A new base replaces the current yearly base. Bonus and commission are saved as history for that month and do not replace it.</p>
      </form>
      </>
      )}

      {selectedSalary && (
        <>
          <h2 className="text-lg font-semibold text-ink">Versions for salary {selectedSalary}</h2>
          <div className="card overflow-hidden">
            <table className="w-full">
              <thead><tr>{["Type", "Amount", "Created at", "Updated at", "Actor"].map((label) => <th key={label} className="th">{label}</th>)}</tr></thead>
              <tbody>
                {versions.map((version, index) => (
                  <tr key={version.id} className={rowClass(index)}>
                    <td className="td">{version.salary_type || "—"}</td>
                    <td className="td">{version.formatted_amount || version.amount ? salaryLabel({ formatted_amount: version.formatted_amount, amount: version.amount, currency: salaries.find((salary) => salary.id === selectedSalary)?.currency }) : "—"}</td>
                    <td className="td">{new Date(version.created_at).toLocaleString()}</td>
                    <td className="td">{version.updated_at ? new Date(version.updated_at).toLocaleString() : "—"}</td>
                    <td className="td">{version.actor ? version.actor.name : "Unknown"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <Pager page={versionMeta.page || 1} perPage={versionMeta.per_page || 25} total={versionMeta.total || 0} onPage={(page) => openVersions(selectedSalary, page)} />
          </div>
        </>
      )}
    </div>
  )
}
