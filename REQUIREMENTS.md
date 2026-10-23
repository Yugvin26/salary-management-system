# Requirements

ACME HR needs one place to keep employee records and compensation history for about 10,000 people across countries, and to answer how the organization pays people without mixing currencies.

## In scope

- HR and employees sign in with one `users` table. Role is `human_resource` or `employee`. Pundit policies enforce access.
- HR registers employees, searches and filters a paginated directory, updates profiles, and archives people instead of deleting them.
- HR records salary lines (amount, ISO currency, type, effective date) with one current line per type. Raises keep the previous line. PaperTrail stores who changed a salary line.
- HR manages departments and locations, and cannot delete one that still has people assigned.
- Dashboard and reports show active headcount and current base pay totals and averages by department, job title, and country, split by currency, plus a CSV export.
- A small seed (~100) and a default seed (~10,000) load a local HR login and demo employee passwords outside production.
- The UI is a React and Material UI SPA served by the Rails app, using a session cookie.

## Out of scope

- Payroll, tax, and banking. Those need compliance controls this assessment does not include.
- Foreign-exchange conversion. Mixing currencies into one total would misstate pay.
- SSO, email delivery, and realtime collaboration. They do not change the HR workflow under test.
- Extra roles and a permission-admin UI. Two roles with policies are enough to show authorization.
- JWT. The SPA is same-origin, so a session cookie is the simpler and safer default.

## Data

`users` holds login and directory fields. `departments` and `locations` group people. `salaries` holds compensation history. `versions` audits salary creates and updates. Reports read current base salaries for active employees only.
