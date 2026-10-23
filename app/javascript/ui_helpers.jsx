import React from "react"

export function rowClass(index) {
  return index % 2 === 0
    ? "bg-stone-50/80 transition hover:bg-teal-50"
    : "bg-white transition hover:bg-teal-50"
}

export function Pager({ page, perPage, total, onPage }) {
  const pages = Math.max(1, Math.ceil((total || 0) / (perPage || 1)))
  return (
    <div className="flex items-center justify-end gap-3 border-t border-stone-100 px-3 py-2 text-sm text-stone-600">
      <span>{total || 0} rows</span>
      <button type="button" className="btn-outline px-3 py-1" disabled={page <= 1} onClick={() => onPage(page - 1)}>Previous</button>
      <span>{page} / {pages}</span>
      <button type="button" className="btn-outline px-3 py-1" disabled={page >= pages} onClick={() => onPage(page + 1)}>Next</button>
    </div>
  )
}

export function generatePassword() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"
  const bytes = new Uint32Array(12)
  crypto.getRandomValues(bytes)
  return Array.from(bytes, (value) => alphabet[value % alphabet.length]).join("")
}

export function PasswordField({ value, onChange, required = true, label }) {
  return (
    <label className="block text-sm font-medium">{label}
      <span className="relative mt-1 block">
        <input
          className="field pr-28"
          type="text"
          autoComplete="new-password"
          required={required}
          value={value}
          onChange={onChange}
        />
        <button
          type="button"
          className="absolute right-1 top-1/2 -translate-y-1/2 rounded-md px-2 py-1 text-xs font-semibold text-ink hover:bg-teal-50"
          onClick={() => onChange({ target: { value: generatePassword() } })}
        >
          Generate
        </button>
      </span>
    </label>
  )
}

export function ErrorBanner({ message, className = "" }) {
  if (!message) return null
  const extra = className ? ` ${className}` : ""
  return <p className={`rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700${extra}`}>{message}</p>
}

export function salaryLabel(row) {
  if (!row) return "—"
  if (row.formatted_amount) return row.formatted_amount
  if (row.amount) return `${row.amount} ${row.currency || ""}`.trim()
  return "—"
}

export function SalaryHistoryTable({ salaries, statusLabel = "Current", action }) {
  const headers = ["Effective", "Type", "Amount", statusLabel]
  if (action) headers.push("")
  return (
    <table className="w-full">
      <thead><tr>{headers.map((label) => <th key={label || "action"} className="th">{label}</th>)}</tr></thead>
      <tbody>
        {salaries.map((salary, index) => (
          <tr key={salary.id} className={rowClass(index)}>
            <td className="td">{salary.effective_on}</td>
            <td className="td">{salary.salary_type}</td>
            <td className="td">{salaryLabel(salary)}</td>
            <td className="td">{salary.current ? <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-semibold text-emerald-800">Current</span> : "History"}</td>
            {action && <td className="td">{action(salary)}</td>}
          </tr>
        ))}
      </tbody>
    </table>
  )
}

export function AuthCard({ title, subtitle, onSubmit, children, tag: Tag = "div" }) {
  return (
    <Tag className="relative flex min-h-screen items-center justify-center overflow-hidden px-4">
      <div className="pointer-events-none absolute inset-0" aria-hidden="true">
        <div className="absolute -left-16 top-8 h-80 w-80 animate-drift rounded-full bg-teal-300/50 blur-3xl" />
        <div className="absolute -right-10 top-1/4 h-96 w-96 animate-drift-reverse rounded-full bg-orange-300/45 blur-3xl" />
        <div className="absolute bottom-0 left-1/3 h-72 w-72 animate-drift-slow rounded-full bg-sky-300/40 blur-3xl" />
      </div>
      <form onSubmit={onSubmit} className="card relative z-10 flex min-h-[44rem] w-full max-w-2xl flex-col justify-center gap-8 px-10 py-16 sm:px-14">
        <div>
          <h1 className="text-3xl font-semibold text-ink">{title}</h1>
          <p className="mt-2 text-base text-stone-500">{subtitle}</p>
        </div>
        {children}
      </form>
    </Tag>
  )
}

export function money(value) {
  const number = Number(value || 0)
  if (number >= 1_000_000_000) return `${(number / 1_000_000_000).toFixed(1)}B`
  if (number >= 1_000_000) return `${(number / 1_000_000).toFixed(1)}M`
  if (number >= 1_000) return `${(number / 1_000).toFixed(1)}k`
  return number.toLocaleString()
}
