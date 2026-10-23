import React, { useEffect, useMemo, useState } from "react"
import { useNavigate } from "react-router-dom"
import { api } from "../api_client"
import { useAuth } from "../auth_context"
import { usePagedList } from "../use_paged_list"
import { ErrorBanner, Pager, rowClass, salaryLabel } from "../ui_helpers"

export default function EmployeeList() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const companyAdmin = user?.role === "company_admin"
  const { rows, meta, error, loading, load: fetchPage } = usePagedList({ cache: true })
  const [departments, setDepartments] = useState([])
  const [locations, setLocations] = useState([])
  const [filters, setFilters] = useState({ q: "", department_id: "", country: "", status: "active", role: "all" })

  const countries = useMemo(() => [...new Set(locations.map((location) => location.country))], [locations])

  function load(page = 1, nextFilters = filters) {
    const params = new URLSearchParams({ page, per_page: 25, status: nextFilters.status })
    if (nextFilters.q) params.set("q", nextFilters.q)
    if (nextFilters.department_id) params.set("department_id", nextFilters.department_id)
    if (nextFilters.country) params.set("country", nextFilters.country)
    if (companyAdmin && nextFilters.role) params.set("role", nextFilters.role)
    fetchPage(`/api/employees?${params}`)
  }

  useEffect(() => {
    api("/api/departments?per_page=100").then((payload) => setDepartments(payload.data))
    api("/api/locations?per_page=100").then((payload) => setLocations(payload.data))
    load(1)
  }, [])

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-semibold text-ink">Employees</h1>
        <button type="button" className="btn-primary" onClick={() => navigate("/employees/new")}>{companyAdmin ? "Register user" : "Register employee"}</button>
      </div>
      <ErrorBanner message={error} />
      <div className="flex flex-wrap items-end gap-3">
        <label className="text-sm font-medium">Search
          <input className="field mt-1" placeholder="Name, email, or ID" value={filters.q} onChange={(event) => setFilters({ ...filters, q: event.target.value })} />
        </label>
        <label className="text-sm font-medium">Department
          <select className="field mt-1" value={filters.department_id} onChange={(event) => setFilters({ ...filters, department_id: event.target.value })}>
            <option value="">All</option>
            {departments.map((department) => <option key={department.id} value={department.id}>{department.name}</option>)}
          </select>
        </label>
        <label className="text-sm font-medium">Country
          <select className="field mt-1" value={filters.country} onChange={(event) => setFilters({ ...filters, country: event.target.value })}>
            <option value="">All</option>
            {countries.map((country) => <option key={country} value={country}>{country}</option>)}
          </select>
        </label>
        {companyAdmin && (
          <label className="text-sm font-medium">Role
            <select className="field mt-1" value={filters.role} onChange={(event) => { const next = { ...filters, role: event.target.value }; setFilters(next); load(1, next) }}>
              <option value="all">All</option>
              <option value="employee">Employees</option>
              <option value="human_resource">HR</option>
            </select>
          </label>
        )}
        <label className="text-sm font-medium">Status
          <select className="field mt-1" value={filters.status} onChange={(event) => setFilters({ ...filters, status: event.target.value })}>
            <option value="active">Active</option>
            <option value="archived">Archived</option>
            <option value="all">All</option>
          </select>
        </label>
        <button type="button" className="btn-outline" onClick={() => load(1)}>Search</button>
      </div>
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr>
              {["ID", "Name", "Role", "Email", "Job title", "Job type", "Department", "Country", "Current base"].map((label) => <th key={label} className="th">{label}</th>)}
            </tr>
          </thead>
          <tbody>
            {loading && [...Array(8)].map((_, idx) => (
              <tr key={`loading-row-${idx}`}><td className="td" colSpan={9}><div className="h-6 animate-pulse rounded bg-stone-200" /></td></tr>
            ))}
            {!loading && rows.map((row, index) => (
              <tr key={row.id} className={`${rowClass(index)} cursor-pointer`} onClick={() => navigate(`/employees/${row.id}`)}>
                <td className="td">{row.employee_id}</td>
                <td className="td">{row.name}</td>
                <td className="td">{row.role === "human_resource" ? "HR" : "Employee"}</td>
                <td className="td">{row.email}</td>
                <td className="td">{row.job_title}</td>
                <td className="td">{row.work_mode ? row.work_mode.replace("_", " ") : "—"}</td>
                <td className="td">{row.department?.name}</td>
                <td className="td">{row.location?.country}</td>
                <td className="td">{salaryLabel(row.current_base_salary)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pager page={meta.page || 1} perPage={meta.per_page || 25} total={meta.total || 0} onPage={load} />
      </div>
    </div>
  )
}
