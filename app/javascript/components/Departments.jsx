import React, { useEffect, useState } from "react"
import { api } from "../api_client"
import { usePagedList } from "../use_paged_list"
import { ErrorBanner, Pager, rowClass } from "../ui_helpers"

export default function Departments() {
  const { rows, meta, error, setError, load: fetchPage } = usePagedList()
  const [name, setName] = useState("")

  function load(page = 1) {
    fetchPage(`/api/departments?page=${page}&per_page=25`)
  }
  useEffect(() => { load(1) }, [])

  async function create(event) {
    event.preventDefault()
    setError("")
    try {
      await api("/api/departments", { method: "POST", body: { department: { name } } })
      setName("")
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  async function remove(id) {
    setError("")
    try {
      await api(`/api/departments/${id}`, { method: "DELETE" })
      load()
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-semibold text-ink">Departments</h1>
      <ErrorBanner message={error} />
      <form onSubmit={create} className="flex flex-wrap items-end gap-3">
        <label className="text-sm font-medium">Name
          <input className="field mt-1" value={name} onChange={(event) => setName(event.target.value)} required />
        </label>
        <button className="btn-primary" type="submit">Add department</button>
      </form>
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead><tr><th className="th">Name</th><th className="th" /></tr></thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={row.id} className={rowClass(index)}>
                <td className="td">{row.name}</td>
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
