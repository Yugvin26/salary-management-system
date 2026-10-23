import React, { useEffect, useState } from "react"
import { api } from "../api_client"
import { usePagedList } from "../use_paged_list"
import { ErrorBanner, Pager, rowClass } from "../ui_helpers"

const empty = { name: "", city: "", country: "" }

export default function Locations() {
  const { rows, meta, error, setError, loading, load: fetchPage } = usePagedList()
  const [form, setForm] = useState(empty)

  function load(page = 1) {
    fetchPage(`/api/locations?page=${page}&per_page=25`)
  }
  useEffect(() => { load(1) }, [])

  async function create(event) {
    event.preventDefault()
    setError("")
    try {
      await api("/api/locations", { method: "POST", body: { location: form } })
      setForm(empty)
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  async function remove(id) {
    setError("")
    try {
      await api(`/api/locations/${id}`, { method: "DELETE" })
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-semibold text-ink">Locations</h1>
      <ErrorBanner message={error} />
      <form onSubmit={create} className="flex flex-wrap items-end gap-3">
        {["name", "city", "country"].map((field) => (
          <label key={field} className="text-sm font-medium capitalize">{field}
            <input className="field mt-1" required value={form[field]} onChange={(event) => setForm({ ...form, [field]: event.target.value })} />
          </label>
        ))}
        <button className="btn-primary" type="submit">Add location</button>
      </form>
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr>{["Name", "City", "Country", ""].map((label) => <th key={label} className="th">{label}</th>)}</tr></thead>
          <tbody>
            {loading && [...Array(5)].map((_, idx) => (
              <tr key={`loading-${idx}`}><td className="td" colSpan={4}><div className="h-6 animate-pulse rounded bg-stone-200" /></td></tr>
            ))}
            {!loading && rows.map((row, index) => (
              <tr key={row.id} className={rowClass(index)}>
                <td className="td">{row.name}</td>
                <td className="td">{row.city}</td>
                <td className="td">{row.country}</td>
                <td className="td text-right"><button type="button" className="btn-danger" onClick={() => remove(row.id)}>Delete</button></td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pager page={meta.page || 1} perPage={meta.per_page || 25} total={meta.total || 0} onPage={load} />
      </div>
    </div>
  )
}
