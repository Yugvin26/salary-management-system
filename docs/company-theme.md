# Company theme

Each company has one `company_settings` row: primary, accent, and background colors as `#rrggbb`.

- A company admin sets them on `/settings` (`GET` and `PATCH /api/company_setting`).
- HR and employees cannot change them.
- After sign-in the SPA writes the colors to `--ink`, `--clay`, and `--sand`. Those variables color the company app, including the dashboard and reports.
- A new company starts with primary `#0f3d4c`, accent `#b8612d`, and background `#f4f1ea`. The site-admin screen keeps its own look.
- The company-admin nav label is "Company theme". HR and employees do not see that link.
