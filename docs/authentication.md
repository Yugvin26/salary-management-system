# Authentication

Company users and the platform owner sign in with email and password. The session is a Devise cookie, not a JWT. See [trade-offs.md](trade-offs.md).

## Company sign-in

`POST /api/session` accepts a company admin, an HR user, or an employee.

- The email and password must match exactly one company user. The same email in two companies is refused, because the login form does not ask for a company.
- Super admins are rejected here. They use `/site-admin`.
- A super admin and a company admin can always sign in. An HR user or an employee must be active. Archiving an employee blocks their next sign-in.
- `GET /api/session` returns the current user, including the company theme. `DELETE /api/session` signs out.

The company login page is `/login`. It links to `/forgot-password` and `/site-admin`.

## Site-admin sign-in

`POST /api/site_admin/session` accepts only `super_admin`. The page is `/site-admin`. After sign-in the super admin stays on the company list and cannot use the company app.

## CSRF

JSON writes send the `CSRF-TOKEN` cookie back as `X-CSRF-Token`. The session cookie is `HttpOnly` and `SameSite=Lax`.
