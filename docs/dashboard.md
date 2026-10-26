# Dashboard

Company admins and HR land on `/` after sign-in. Employees are sent to `/me`. A super admin never sees this page.

`GET /api/reports/dashboard` returns the signed-in company's active headcount and current base pay grouped by currency. Bonus and commission are not included. Currencies are not converted, and there is no grand total.

The page shows:

- Active headcount
- A table of currency, headcount, and current base total
- A carousel of four charts: headcount by currency, current base pay by currency, headcount share, and pay mix

An empty company shows "No data to show" instead of a chart. Charts appear after the company has active employees with a current base salary. Grouped tables and CSV downloads live on `/reports`. See [reports.md](reports.md).
