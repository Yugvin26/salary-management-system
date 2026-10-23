import React, { useEffect, useMemo, useState } from "react"
import { useNavigate, useParams } from "react-router-dom"
import { api, errorMessage } from "../api_client"
import { useAuth } from "../auth_context"
import { ErrorBanner, generatePassword, PasswordField } from "../ui_helpers"

const jobTitleOptions = [
  "Software Engineer",
  "Senior Software Engineer",
  "Engineering Manager",
  "Product Manager",
  "Account Executive",
  "HR Partner",
  "Financial Analyst",
  "Support Specialist",
  "People Operations Specialist"
]

const workModeOptions = [
  { value: "remote", label: "Remote" },
  { value: "hybrid", label: "Hybrid" },
  { value: "in_office", label: "In-office" }
]

const empty = {
  first_name: "", last_name: "", email: "", password: "", employee_id: "",
  job_title: "", work_mode: "", hire_date: "", department_id: "", location_id: "", role: "employee"
}

export default function EmployeeForm() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { user } = useAuth()
  const companyAdmin = user?.role === "company_admin"
  const [form, setForm] = useState(() => ({ ...empty, password: id ? "" : generatePassword() }))
  const hrRole = companyAdmin && form.role === "human_resource"
  const [departments, setDepartments] = useState([])
  const [locations, setLocations] = useState([])
  const [error, setError] = useState("")

  useEffect(() => {
    if (!hrRole) return
    const hrDepartment = departments.find((department) => department.name.trim().toLowerCase() === "hr")
    setForm((current) => ({
      ...current,
      job_title: "HR Partner",
      department_id: hrDepartment ? String(hrDepartment.id) : current.department_id
    }))
  }, [hrRole, departments])

  useEffect(() => {
    api("/api/departments?per_page=100").then((payload) => setDepartments(payload.data))
    api("/api/locations?per_page=100").then((payload) => setLocations(payload.data))
    if (id) {
      api(`/api/employees/${id}`).then((payload) => {
        const employee = payload.data
        setForm({
          first_name: employee.first_name,
          last_name: employee.last_name,
          email: employee.email,
          password: "",
          employee_id: employee.employee_id,
          job_title: employee.job_title,
          work_mode: employee.work_mode || "",
          hire_date: employee.hire_date,
          department_id: employee.department?.id || "",
          location_id: employee.location?.id || "",
          role: employee.role || "employee"
        })
      })
    }
  }, [id])

  function set(field) {
    return (event) => setForm({ ...form, [field]: event.target.value })
  }

  function generateEmployeeId() {
    const random = Math.floor(10_000 + Math.random() * 90_000)
    setForm((current) => ({ ...current, employee_id: `E${random}` }))
  }

  const isCustomJobTitle = useMemo(
    () => form.job_title && !jobTitleOptions.includes(form.job_title),
    [form.job_title]
  )

  async function submit(event) {
    event.preventDefault()
    setError("")
    const body = { employee: { ...form } }
    if (id && !body.employee.password) delete body.employee.password
    try {
      const payload = id
        ? await api(`/api/employees/${id}`, { method: "PATCH", body })
        : await api("/api/employees", { method: "POST", body })
      navigate(`/employees/${payload.data.id}`)
    } catch (err) {
      setError(errorMessage(err.payload))
    }
  }

  return (
    <form onSubmit={submit} className="card mx-auto w-full max-w-3xl p-6">
      <h1 className="text-3xl font-semibold text-ink">{id ? "Edit user" : companyAdmin ? "Register user" : "Register employee"}</h1>
      <div className="mt-2 flex flex-wrap gap-2">
        <span className="rounded-full bg-ink px-3 py-1 text-xs font-medium text-white">Employee record</span>
        <span className="rounded-full border border-ink/20 px-3 py-1 text-xs font-medium text-ink">ID supports auto/manual mode</span>
      </div>
      <ErrorBanner message={error} className="mt-4" />
      <div className="mt-4 grid gap-3 md:grid-cols-2">
        <label className="text-sm font-medium">First name
          <input className="field mt-1" required value={form.first_name} onChange={set("first_name")} />
        </label>
        <label className="text-sm font-medium">Last name
          <input className="field mt-1" required value={form.last_name} onChange={set("last_name")} />
        </label>
        <label className="text-sm font-medium md:col-span-2">Email
          <input className="field mt-1" type="email" required value={form.email} onChange={set("email")} />
        </label>
        <div className="md:col-span-2">
          <PasswordField
            label={id ? "Password (leave blank to keep)" : "Password"}
            required={!id}
            value={form.password}
            onChange={set("password")}
          />
        </div>
        {companyAdmin && (
          <label className="text-sm font-medium md:col-span-2">Role
            <select className="field mt-1" value={form.role} onChange={set("role")}>
              <option value="employee">Employee</option>
              <option value="human_resource">HR</option>
            </select>
          </label>
        )}
        <label className="text-sm font-medium md:col-span-2">Employee ID
          <span className="mt-1 flex gap-2">
            <input className="field" required value={form.employee_id} onChange={set("employee_id")} placeholder="E12345" />
            <button type="button" className="btn-outline shrink-0" title="Generate ID in format E12345" onClick={generateEmployeeId}>Hint / Generate</button>
          </span>
          <span className="mt-1 block text-xs text-stone-500">Format: E12345 (auto-generated if blank)</span>
        </label>
        <label className="text-sm font-medium">Job title
          {hrRole ? (
            <input className="field mt-1 bg-stone-100" value="HR Partner" readOnly disabled />
          ) : (
            <select
              className="field mt-1"
              required
              value={isCustomJobTitle ? "custom" : form.job_title}
              onChange={(event) => {
                const value = event.target.value
                setForm((current) => ({ ...current, job_title: value === "custom" ? "" : value }))
              }}
            >
              <option value="">Select</option>
              {jobTitleOptions.map((title) => <option key={title} value={title}>{title}</option>)}
              <option value="custom">Other (custom)</option>
            </select>
          )}
        </label>
        <label className="text-sm font-medium">Job type
          <select className="field mt-1" required value={form.work_mode} onChange={set("work_mode")}>
            <option value="">Select</option>
            {workModeOptions.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}
          </select>
        </label>
        {!hrRole && (isCustomJobTitle || form.job_title === "") && (
          <label className="text-sm font-medium md:col-span-2">Custom job title
            <input className="field mt-1" required value={form.job_title} onChange={set("job_title")} />
          </label>
        )}
        <label className="text-sm font-medium">Hire date
          <input className="field mt-1" type="date" required value={form.hire_date || ""} onChange={set("hire_date")} />
        </label>
        <label className="text-sm font-medium">Department
          {hrRole ? (
            <input className="field mt-1 bg-stone-100" value="HR" readOnly disabled />
          ) : (
            <select className="field mt-1" required value={form.department_id} onChange={set("department_id")}>
              <option value="">Select</option>
              {departments.map((department) => <option key={department.id} value={department.id}>{department.name}</option>)}
            </select>
          )}
        </label>
        <label className="text-sm font-medium md:col-span-2">Location
          <select className="field mt-1" required value={form.location_id} onChange={set("location_id")}>
            <option value="">Select</option>
            {locations.map((location) => <option key={location.id} value={location.id}>{location.name} — {location.country}</option>)}
          </select>
        </label>
      </div>
      <button className="btn-primary mt-5" type="submit">Save</button>
    </form>
  )
}
