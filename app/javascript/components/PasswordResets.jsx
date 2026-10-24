import React, { useEffect, useState } from "react"
import { api } from "../api_client"
import { usePagedList } from "../use_paged_list"
import { ErrorBanner, generatePassword, Pager, PasswordField, rowClass } from "../ui_helpers"

export default function PasswordResets() {
  const { rows, meta, error, setError, load: fetchPage } = usePagedList()
  const [passwords, setPasswords] = useState({})
  const [notice, setNotice] = useState("")

  function load(page = 1) {
    fetchPage(`/api/password_reset_requests?page=${page}&per_page=25`, {
      onSuccess(payload) {
        setPasswords(Object.fromEntries(payload.data.filter((row) => row.status === "pending").map((row) => [row.id, generatePassword()])))
      }
    })
  }

  useEffect(() => { load(1) }, [])

  async function reset(row) {
    setError("")
    setNotice("")
    try {
      await api(`/api/password_reset_requests/${row.id}`, {
        method: "PATCH",
        body: { password: passwords[row.id], password_confirmation: passwords[row.id] }
      })
      setNotice(`Password updated for ${row.user.email}.`)
      load(meta.page || 1)
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-semibold text-ink">Password resets</h1>
      <p className="text-sm text-stone-600">Employees who asked for a new password. Set one and share it with them.</p>
      <ErrorBanner message={error} />
      {notice && <p className="rounded-lg bg-emerald-50 px-3 py-2 text-sm text-emerald-800">{notice}</p>}
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr>{["Employee", "Email", "Requested", "Status", "New password"].map((label) => <th key={label} className="th">{label}</th>)}</tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={row.id} className={rowClass(index)}>
                <td className="td">{row.user.name}<div className="text-xs text-stone-500">{row.user.employee_id}</div></td>
                <td className="td">{row.user.email}</td>
                <td className="td">{new Date(row.requested_at).toLocaleString()}</td>
                <td className="td">{row.status === "pending" ? "Pending" : "Completed"}</td>
                <td className="td">
                  {row.status === "pending" ? (
                    <form className="flex items-end gap-2" onSubmit={(event) => { event.preventDefault(); reset(row) }}>
                      <div className="min-w-64">
                        <PasswordField
                          label="Password"
                          value={passwords[row.id] || ""}
                          onChange={(event) => setPasswords({ ...passwords, [row.id]: event.target.value })}
                        />
                      </div>
                      <button className="btn-primary mb-0.5" type="submit">Set password</button>
                    </form>
                  ) : "—"}
                </td>
              </tr>
            ))}
            {rows.length === 0 && <tr><td className="td" colSpan={5}>No password reset requests.</td></tr>}
          </tbody>
        </table>
        <Pager page={meta.page || 1} perPage={meta.per_page || 25} total={meta.total || 0} onPage={load} />
      </div>
    </div>
  )
}
