# Monthly payout

The profile shows what to pay this calendar month. It is on the employee or HR profile for staff, and on `/me` for the person themselves.

The stored base is a yearly amount. This month's payout is:

1. One twelfth of the current base, rounded to the currency's minor units.
2. Plus every bonus whose effective date is in the current month.
3. Plus every commission whose effective date is in the current month.

Older bonuses and commissions stay in salary history and are not added again. A new base replaces the yearly amount used for later months. It does not rewrite a past month.

If there is no current base, the base portion is zero and this month's bonus and commission still count. If the person has no salary lines, the payout card is omitted.

The salaries index returns the same figures in `meta.monthly_payout`. The profile payload includes `monthly_payout`.
