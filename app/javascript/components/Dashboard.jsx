import React, { useEffect, useState } from "react"
import { Bar, BarChart, CartesianGrid, Cell, Legend, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts"
import { api } from "../api_client"
import { ErrorBanner, money, rowClass } from "../ui_helpers"

const palette = [
  ["#2dd4bf", "#0f766e"],
  ["#fb923c", "#c2410c"],
  ["#818cf8", "#4338ca"],
  ["#fb7185", "#be123c"],
  ["#fbbf24", "#b45309"]
]

function chartFill(currency, index, horizontal = false) {
  return `url(#${horizontal ? "h" : "v"}-${currency || index})`
}

function GradientDefs({ rows, horizontal = false }) {
  return (
    <defs>
      {rows.map((row, index) => {
        const [from, to] = palette[index % palette.length]
        const id = `${horizontal ? "h" : "v"}-${row.currency}`
        return (
          <linearGradient key={id} id={id} x1="0" y1="0" x2={horizontal ? "1" : "0"} y2={horizontal ? "0" : "1"}>
            <stop offset="0%" stopColor={from} />
            <stop offset="100%" stopColor={to} />
          </linearGradient>
        )
      })}
    </defs>
  )
}

export default function Dashboard() {
  const [data, setData] = useState(null)
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(true)
  const rows = (data?.base_pay_by_currency || []).map((row) => ({
    ...row,
    total: Number(row.total),
    headcount: Number(row.headcount)
  }))
  const [slide, setSlide] = useState(0)
  const headcountMax = Math.max(...rows.map((row) => row.headcount), 1)
  const totalMax = Math.max(...rows.map((row) => row.total), 1)
  const slides = [
    {
      title: "Headcount by currency",
      chart: (
        <ResponsiveContainer>
          <BarChart data={rows} margin={{ top: 16, right: 36, left: 12, bottom: 8 }}>
            {GradientDefs({ rows })}
            <CartesianGrid stroke="#e7e5e4" strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="currency" tick={{ fill: "#57534e", fontSize: 13 }} axisLine={false} tickLine={false} />
            <YAxis width={64} domain={[0, Math.ceil(headcountMax * 1.15)]} allowDecimals={false} tick={{ fill: "#57534e", fontSize: 13 }} axisLine={false} tickLine={false} />
            <Tooltip cursor={{ fill: "rgba(15,61,76,0.06)" }} />
            <Bar dataKey="headcount" name="Headcount" radius={[8, 8, 0, 0]}>
              {rows.map((row, index) => <Cell key={row.currency} fill={chartFill(row.currency, index)} />)}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      )
    },
    {
      title: "Current base pay by currency",
      chart: (
        <ResponsiveContainer>
          <BarChart data={rows} margin={{ top: 16, right: 36, left: 16, bottom: 8 }}>
            {GradientDefs({ rows })}
            <CartesianGrid stroke="#e7e5e4" strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="currency" tick={{ fill: "#57534e", fontSize: 13 }} axisLine={false} tickLine={false} />
            <YAxis width={80} domain={[0, totalMax * 1.1]} tickFormatter={money} tick={{ fill: "#57534e", fontSize: 13 }} axisLine={false} tickLine={false} />
            <Tooltip cursor={{ fill: "rgba(15,61,76,0.06)" }} formatter={(value) => Number(value).toLocaleString()} />
            <Bar dataKey="total" name="Current base total" radius={[8, 8, 0, 0]}>
              {rows.map((row, index) => <Cell key={row.currency} fill={chartFill(row.currency, index)} />)}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      )
    },
    {
      title: "Headcount share",
      chart: (
        <ResponsiveContainer>
          <PieChart>
            <Pie data={rows} dataKey="headcount" nameKey="currency" innerRadius="46%" outerRadius="78%" paddingAngle={4} stroke="#fff" strokeWidth={3}>
              {rows.map((row, index) => <Cell key={row.currency} fill={palette[index % palette.length][1]} />)}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      )
    },
    {
      title: "Pay mix (not converted)",
      chart: (
        <ResponsiveContainer>
          <BarChart data={rows} layout="vertical" margin={{ top: 16, right: 48, left: 16, bottom: 8 }}>
            {GradientDefs({ rows, horizontal: true })}
            <CartesianGrid stroke="#e7e5e4" strokeDasharray="3 3" horizontal={false} />
            <XAxis type="number" tickFormatter={money} tick={{ fill: "#57534e", fontSize: 13 }} axisLine={false} tickLine={false} />
            <YAxis type="category" dataKey="currency" width={56} tick={{ fill: "#57534e", fontSize: 13 }} axisLine={false} tickLine={false} />
            <Tooltip cursor={{ fill: "rgba(15,61,76,0.06)" }} formatter={(value) => Number(value).toLocaleString()} />
            <Bar dataKey="total" name="Current base total" radius={[0, 8, 8, 0]}>
              {rows.map((row, index) => <Cell key={row.currency} fill={chartFill(row.currency, index, true)} />)}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      )
    }
  ]
  const previousIndex = (slide - 1 + slides.length) % slides.length
  const nextIndex = (slide + 1) % slides.length

  useEffect(() => {
    setLoading(true)
    api("/api/reports/dashboard")
      .then((payload) => setData(payload.data))
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-semibold text-ink">Dashboard</h1>
      <p className="rounded-xl bg-sky-50 px-4 py-3 text-sm text-sky-900">Amounts stay in their original currency. This page does not convert currencies or show a single grand total.</p>
      <ErrorBanner message={error} />
      {loading && <div className="card h-72 animate-pulse bg-stone-100" />}
      {data && !loading && (
        <>
          <p className="text-lg font-medium">Active headcount: {data.active_headcount}</p>
          {rows.length === 0 ? (
            <section className="card flex min-h-[20rem] items-center justify-center p-10 text-center">
              <div>
                <h2 className="text-2xl font-semibold text-ink">No data to show</h2>
                <p className="mt-2 text-sm text-stone-600">Charts appear after this company has active employees with a current base salary.</p>
              </div>
            </section>
          ) : (
          <>
          <section className="card flex h-[calc(100vh-18rem)] min-h-[32rem] w-full flex-col p-5">
            <div className="flex items-end justify-between gap-4">
              <h2 className="text-2xl font-semibold text-ink">{slides[slide].title}</h2>
              <p className="text-sm text-stone-500">{slide + 1} / {slides.length}</p>
            </div>
            <div className="relative mt-2 min-h-0 flex-1">
              <div className="absolute inset-0 overflow-hidden">
                {slides.map((item, index) => (
                  <div
                    key={item.title}
                    className={`absolute inset-0 px-12 transition-all duration-500 ease-out ${index === slide ? "translate-x-0 opacity-100" : index < slide ? "-translate-x-full opacity-0" : "translate-x-full opacity-0"}`}
                  >
                    {item.chart}
                  </div>
                ))}
              </div>
              <button
                type="button"
                aria-label={`Previous: ${slides[previousIndex].title}`}
                title={slides[previousIndex].title}
                onClick={() => setSlide(previousIndex)}
                className="absolute left-2 top-1/2 z-10 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full bg-ink text-white shadow-lg transition duration-200 hover:scale-110 hover:bg-teal-600"
              >
                <svg viewBox="0 0 20 20" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2.2" aria-hidden="true">
                  <path d="M12.5 4.5 7 10l5.5 5.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </button>
              <button
                type="button"
                aria-label={`Next: ${slides[nextIndex].title}`}
                title={slides[nextIndex].title}
                onClick={() => setSlide(nextIndex)}
                className="absolute right-2 top-1/2 z-10 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full bg-ink text-white shadow-lg transition duration-200 hover:scale-110 hover:bg-teal-600"
              >
                <svg viewBox="0 0 20 20" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2.2" aria-hidden="true">
                  <path d="M7.5 4.5 13 10l-5.5 5.5" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </button>
            </div>
          </section>
          <div className="card overflow-hidden">
            <table className="w-full">
              <thead><tr><th className="th">Currency</th><th className="th text-right">Headcount</th><th className="th text-right">Current base total</th></tr></thead>
              <tbody>
                {rows.map((row, index) => (
                  <tr key={row.currency} className={rowClass(index)}>
                    <td className="td">{row.currency}</td>
                    <td className="td text-right">{row.headcount}</td>
                    <td className="td text-right">{row.formatted_total || Number(row.total).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          </>
          )}
        </>
      )}
    </div>
  )
}
