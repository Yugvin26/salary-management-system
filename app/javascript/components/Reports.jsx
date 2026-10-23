import React, { useEffect, useState } from "react"
import { usePagedList } from "../use_paged_list"
import { ErrorBanner, Pager, rowClass } from "../ui_helpers"

const tabs = [
  ["departments", "Department", "/api/reports/departments", "department"],
  ["job_titles", "Job title", "/api/reports/job_titles", "job_title"],
  ["countries", "Country", "/api/reports/countries", "country"]
]

export default function Reports() {
  const [tab, setTab] = useState(0)
  const { rows, meta, error, loading, load: fetchPage } = usePagedList({ cache: true })
  const current = tabs[tab]

  function load(page = 1) {
    fetchPage(`${current[2]}?page=${page}&per_page=25`)
  }

  useEffect(() => {
    load(1)
  }, [tab])

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-semibold text-ink">Pay reports</h1>
      <p className="rounded-xl bg-sky-50 px-4 py-3 text-sm text-sky-900">Totals and averages are per currency. USD and EUR are listed separately. There is no converted grand total.</p>
      <a className="btn-primary" href="/api/reports/export" title="Employee data for payroll">Download CSV</a>
      <ErrorBanner message={error} />
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex gap-1 rounded-xl bg-white/80 p-1">
          {tabs.map(([key, label], index) => (
            <button
              key={key}
              type="button"
              onClick={() => setTab(index)}
              className={`rounded-lg px-3 py-2 text-sm font-medium transition ${tab === index ? "bg-ink text-white shadow" : "text-stone-700 hover:bg-teal-50"}`}
            >
              {label}
            </button>
          ))}
        </div>
        <a className="btn-outline" href={`/api/reports/export_grouped?grouped_type=${current[0]}`}>
          Download {current[1]} data
        </a>
      </div>
      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr>
              <th className="th">{current[1]}</th>
              <th className="th">Currency</th>
              <th className="th text-right">Headcount</th>
              <th className="th text-right">Total</th>
              <th className="th text-right">Average</th>
            </tr>
          </thead>
          <tbody>
            {loading && [...Array(6)].map((_, index) => (
              <tr key={`skeleton-${index}`}><td className="td" colSpan={5}><div className="h-6 animate-pulse rounded bg-stone-200" /></td></tr>
            ))}
            {!loading && rows.map((row, index) => (
              <tr key={`${row[current[3]]}-${row.currency}-${index}`} className={rowClass(index)}>
                <td className="td">{row[current[3]]}</td>
                <td className="td">{row.currency}</td>
                <td className="td text-right">{row.headcount}</td>
                <td className="td text-right">{row.formatted_total || row.total}</td>
                <td className="td text-right">{row.formatted_average || row.average}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <Pager page={meta.page || 1} perPage={meta.per_page || 25} total={meta.total || 0} onPage={load} />
      </div>
    </div>
  )
}
