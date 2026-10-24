import React, { useEffect, useState } from "react"
import { api, errorMessage } from "../api_client"
import { useAuth, useSignOut } from "../auth_context"
import { usePagedList } from "../use_paged_list"
import { AuthCard, ErrorBanner, generatePassword, Pager, PasswordField, rowClass } from "../ui_helpers"

const empty = { name: "", admin_first_name: "", admin_last_name: "", admin_email: "", admin_password: "" }

export default function SiteAdmin() {
  const { user, ready, setUser } = useAuth()
  const signOut = useSignOut("/site-admin")
  const [credentials, setCredentials] = useState({ email: "", password: "" })
  const [loginError, setLoginError] = useState("")
  const { rows, meta, error, setError, load: fetchPage } = usePagedList()
  const [form, setForm] = useState(empty)
  const [editingId, setEditingId] = useState(null)
  const [modalOpen, setModalOpen] = useState(false)
  const [formError, setFormError] = useState("")

  function load(page = 1) {
    fetchPage(`/api/site_admin/companies?page=${page}&per_page=25`)
  }

  useEffect(() => {
    if (user?.role === "super_admin") load(1)
  }, [user])

  async function signIn(event) {
    event.preventDefault()
    setLoginError("")
    try {
      const payload = await api("/api/site_admin/session", { method: "POST", body: credentials })
      setUser(payload.data)
    } catch (err) {
      setLoginError(errorMessage(err.payload))
    }
  }

  function closeModal() {
    setModalOpen(false)
    setEditingId(null)
    setForm(empty)
    setFormError("")
  }

  function openCreate() {
    setEditingId(null)
    setForm({ ...empty, admin_password: generatePassword() })
    setFormError("")
    setModalOpen(true)
  }

  async function save(event) {
    event.preventDefault()
    setFormError("")
    const body = { company: form }
    try {
      if (editingId) {
        await api(`/api/site_admin/companies/${editingId}`, { method: "PATCH", body })
      } else {
        await api("/api/site_admin/companies", { method: "POST", body })
      }
      closeModal()
      load(meta.page || 1)
    } catch (err) {
      setFormError(errorMessage(err.payload))
    }
  }

  function edit(row) {
    setEditingId(row.id)
    setFormError("")
    setForm({
      name: row.name,
      admin_first_name: row.admin?.name?.split(" ")[0] || "",
      admin_last_name: row.admin?.name?.split(" ").slice(1).join(" ") || "",
      admin_email: row.admin?.email || "",
      admin_password: ""
    })
    setModalOpen(true)
  }

  async function remove(id) {
    setError("")
    try {
      await api(`/api/site_admin/companies/${id}`, { method: "DELETE" })
      load(1)
    } catch (err) {
      setError(err.message)
    }
  }

  if (!ready) return <div className="p-8 text-sm text-stone-500">Loading session…</div>

  if (user?.role !== "super_admin") {
    return (
      <AuthCard tag="main" title="Site admin" subtitle="Sign in with the super admin email and password." onSubmit={signIn}>
          <ErrorBanner message={loginError} />
          <label className="block text-base font-medium">Email
            <input className="field mt-2 py-3.5 text-base" type="email" required value={credentials.email} onChange={(event) => setCredentials({ ...credentials, email: event.target.value })} />
          </label>
          <label className="block text-base font-medium">Password
            <input className="field mt-2 py-3.5 text-base" type="password" required value={credentials.password} onChange={(event) => setCredentials({ ...credentials, password: event.target.value })} />
          </label>
          <button className="btn-primary w-full py-3.5 text-base" type="submit">Sign in</button>
          <p className="text-center text-sm text-stone-500">
            Company staff? <a className="font-semibold text-ink underline-offset-2 hover:underline" href="/login">Back to sign in</a>
          </p>
      </AuthCard>
    )
  }

  return (
    <main className="min-h-screen px-6 py-8">
      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-3xl font-semibold text-ink">Companies</h1>
        <div className="flex gap-2">
          <button type="button" className="btn-primary" onClick={openCreate}>New company</button>
          <button type="button" className="btn-outline" onClick={signOut}>Sign out</button>
        </div>
      </div>
      <ErrorBanner message={error} className="mb-4" />
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr>{["Company", "Admin", "Email", ""].map((label) => <th key={label} className="th">{label}</th>)}</tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={row.id} className={rowClass(index)}>
                <td className="td">{row.name}</td>
                <td className="td">{row.admin?.name || "—"}</td>
                <td className="td">{row.admin?.email || "—"}</td>
                <td className="td text-right">
                  <button type="button" className="btn-outline mr-2 px-2.5 py-1 text-xs" onClick={() => edit(row)}>Edit</button>
                  <button type="button" className="btn-danger" onClick={() => remove(row.id)}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pager page={meta.page || 1} perPage={meta.per_page || 25} total={meta.total || 0} onPage={load} />
      </div>
      {modalOpen && (
        <CompanyModal
          editing={Boolean(editingId)}
          form={form}
          setForm={setForm}
          error={formError}
          onClose={closeModal}
          onSubmit={save}
        />
      )}
    </main>
  )
}

function CompanyModal({ editing, form, setForm, error, onClose, onSubmit }) {
  useEffect(() => {
    function onKey(event) {
      if (event.key === "Escape") onClose()
    }
    window.addEventListener("keydown", onKey)
    return () => window.removeEventListener("keydown", onKey)
  }, [onClose])

  const fields = [
    ["name", "Company name", "text"],
    ["admin_first_name", "Admin first name", "text"],
    ["admin_last_name", "Admin last name", "text"],
    ["admin_email", "Admin email", "email"],
    ["admin_password", editing ? "New admin password" : "Admin password", "password"]
  ]

  return (
    <div className="fixed inset-0 z-30 flex items-center justify-center bg-ink/40 px-4 backdrop-blur-sm" onClick={onClose}>
      <form
        role="dialog"
        aria-modal="true"
        aria-labelledby="company-modal-title"
        onClick={(event) => event.stopPropagation()}
        onSubmit={onSubmit}
        className="card w-full max-w-lg space-y-4 p-6"
      >
        <div>
          <h2 id="company-modal-title" className="text-2xl font-semibold text-ink">{editing ? "Edit company" : "Create company"}</h2>
          <p className="mt-1 text-sm text-stone-500">
            {editing ? "Update this company and its admin." : "Add a company and its first admin."}
          </p>
        </div>
        <ErrorBanner message={error} />
        {fields.filter(([key]) => key !== "admin_password").map(([key, label, type]) => (
          <label key={key} className="block text-sm font-medium">{label}
            <input
              className="field mt-1"
              type={type}
              required
              value={form[key]}
              onChange={(event) => setForm({ ...form, [key]: event.target.value })}
            />
          </label>
        ))}
        <PasswordField
          label={editing ? "New admin password" : "Admin password"}
          required={!editing}
          value={form.admin_password}
          onChange={(event) => setForm({ ...form, admin_password: event.target.value })}
        />
        <div className="flex justify-end gap-2 pt-2">
          <button type="button" className="btn-outline" onClick={onClose}>Cancel</button>
          <button className="btn-primary" type="submit">{editing ? "Save changes" : "Create company"}</button>
        </div>
      </form>
    </div>
  )
}
