import React from "react"

export default function MonthlyPayout({ payout }) {
  if (!payout?.currency) return null

  const rows = [
    ["Base this month", payout.formatted_base_monthly, payout.formatted_base_annual ? `one twelfth of yearly ${payout.formatted_base_annual}` : "no current base"],
    ["Bonus this month", payout.formatted_bonus, "one-month payout"],
    ["Commission this month", payout.formatted_commission, "one-month payout"]
  ]

  return (
    <section className="card space-y-3 p-4">
      <div>
        <h2 className="text-lg font-semibold text-ink">This month ({payout.month})</h2>
        <p className="mt-1 text-sm text-stone-600">The yearly base stays current. This month pays one twelfth of it, plus any bonus or commission dated this month.</p>
      </div>
      <dl className="grid gap-3 sm:grid-cols-3">
        {rows.map(([label, amount, note]) => (
          <div key={label}>
            <dt className="text-xs font-semibold uppercase tracking-wide text-stone-500">{label}</dt>
            <dd className="text-lg font-semibold text-ink">{amount}</dd>
            <dd className="text-xs text-stone-500">{note}</dd>
          </div>
        ))}
      </dl>
      <p className="text-sm font-semibold text-ink">Monthly payout {payout.formatted_total}</p>
    </section>
  )
}
