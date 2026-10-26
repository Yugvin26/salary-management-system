# Reports

Company admins and HR open `/reports`. Employees cannot. Every figure is limited to the signed-in company.

Reports use the current base salary of active employees. Bonus and commission are not included, and amounts are never converted between currencies. Each group is split by currency.

The page has three tabs: department, job title, and country. Each table shows the group, currency, headcount, total, and average, 25 rows per page.

- `GET /api/reports/export` downloads `employee-payroll.csv`: employee ID, name, department, country, job title, location, current base amount, and currency. The file includes employee-role users only.
- `GET /api/reports/export_grouped?grouped_type=departments|job_titles|countries` downloads that tab as CSV. An unknown `grouped_type` is rejected.

The dashboard charts are a separate page. See [dashboard.md](dashboard.md).
