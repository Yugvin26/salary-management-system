# Salary management

Rails 8 monolith with a React and Tailwind CSS SPA, PostgreSQL, Devise session cookies, Pundit, and PaperTrail on salary lines. Each company has its own people, departments, locations, salaries, and theme. A super admin creates companies. A company admin or HR user runs that company. Employees can sign in and read only their own profile, salary history, and this month's payout.

## Features

| Feature | Doc |
| --- | --- |
| Sign-in, sessions, and CSRF | [docs/authentication.md](docs/authentication.md) |
| Companies and tenancy | [docs/companies.md](docs/companies.md) |
| Super admin, company admin, HR, and employee | [docs/roles.md](docs/roles.md) |
| Company colors | [docs/company-theme.md](docs/company-theme.md) |
| Directory, registration, profile, archive | [docs/employees.md](docs/employees.md) |
| Employee home at `/me` | [docs/self-profile.md](docs/self-profile.md) |
| Departments and locations | [docs/departments-and-locations.md](docs/departments-and-locations.md) |
| Yearly base and one-month bonus or commission | [docs/salaries.md](docs/salaries.md) |
| PaperTrail on a salary line | [docs/salary-versions.md](docs/salary-versions.md) |
| This month's payout | [docs/monthly-payout.md](docs/monthly-payout.md) |
| Forgot password and employee reset requests | [docs/password-resets.md](docs/password-resets.md) |
| Dashboard charts | [docs/dashboard.md](docs/dashboard.md) |
| Pay reports and CSV | [docs/reports.md](docs/reports.md) |
| Indexes and seed size | [docs/performance.md](docs/performance.md) |
| Session cookies and one users table | [docs/trade-offs.md](docs/trade-offs.md) |

## Stack

- Ruby 3.3, Rails 8, PostgreSQL 16
- React 18, React Router, Recharts, Tailwind CSS, esbuild (`jsbundling-rails`), Propshaft
- Money handled with `money-rails`, pagination with `pagy`, plain Ruby serializers in `app/serializers`
- Devise database auth with an HTTP session cookie (not JWT)
- Pundit policies on a single `users` table (`super_admin`, `company_admin`, `human_resource`, `employee`)
- PaperTrail versions on `salaries` only
- Amounts stay in their original currency. There is no FX conversion.

## Run with Docker Compose

```bash
cp .env.example .env
docker compose up --build
```

Open http://localhost:3000. The `web` service runs Foreman (`bin/dev`) with three processes from `Procfile.dev`: Puma on `0.0.0.0:3000`, the Tailwind CSS watch and the esbuild JS watch. Postgres is the `db` service.

Load the small workforce (about 100 employees):

```bash
docker compose run --rm -e SEED_PROFILE=small web bin/rails db:seed
```

The assessment demo set is about 10,000 employees:

```bash
docker compose run --rm -e SEED_PROFILE=default web bin/rails db:seed
```

A `large` profile (about 200,000 employees) is also available. Profiles can be run through `db:seed` with `SEED_PROFILE`, or directly with `bin/rails db:seed:small`, `db:seed:default` and `db:seed:large`. All of them refuse to run when `RAILS_ENV=production`. Seed code lives in `lib/seeding`.

### Local HR and employee logins

These passwords are for local and demo databases only.

| Who | Email | Password | Where |
| --- | --- | --- | --- |
| Super admin | `superadmin@acme.local` | `password` (override with `HR_PASSWORD`) | `/site-admin` |
| Company admin | `admin@acme.local` | `password` (override with `HR_PASSWORD`) | `/login` |
| HR manager | `hr@acme.local` | `password` (override with `HR_PASSWORD`) | `/login` |
| Seeded employee | `employee0001@acme.local` | `DemoPass123!` | `/login` |

Every seeded employee uses `DemoPass123!`.

## Foreman without Compose

If Postgres is already reachable, put its URL in `.env` and run:

```bash
bin/dev
```

That starts Puma, `yarn build:css --watch` and `yarn build:js --watch`.

## Tests

```bash
docker compose run --rm -e RAILS_ENV=test web bundle exec rspec
```

The RSpec suite has model, policy, query, serializer, service and request specs under `spec/`. It does not run the 10,000-row seed. There are no frontend tests. Frontend assets (Tailwind CSS and JS):

```bash
yarn build
```

## Architecture

- One `users` table for the super admin, company admins, HR, and employees. There is no `employees` table and no separate admin table. Employee-role rows carry employee ID, job title, job type, hire date, department, location, and active flag. Archive sets `active` to false. Job types are remote, hybrid, and in-office.
- Companies scope email, employee ID, department name, and location name. Feature rules are in the docs linked above.
- Business logic sits in query objects (`app/queries/employees`, `app/queries/reports`) and `app/services/workforce`. Controllers under `app/controllers/api` stay thin.
- Pundit: company admins and HR manage their company. Only a company admin assigns the HR role or the theme. Employees read their own profile and salary history at `/me`. A company admin or HR user can add a salary for someone else, including another HR user, and cannot change their own. The directory filters by name, department, country, and status. A company admin can also filter by role.
- A department or location cannot be deleted while people are still assigned.
- Same-origin session cookie (`HttpOnly`, `SameSite=Lax`). JSON writes send the `CSRF-TOKEN` cookie back as `X-CSRF-Token`. A separate React origin would be a better fit for JWT; this app is one origin, so a cookie avoids token storage and a logout blacklist. See `docs/trade-offs.md`.
- A new current base marks the previous base as history. Bonus and commission are one-month history lines and do not replace the base. This month's payout is one twelfth of the current yearly base plus bonus and commission dated this month. PaperTrail records salary creates and updates, including `whodunnit`. Bulk seed disables PaperTrail so the large load stays fast. Later edits in the app are versioned.
- The dashboard charts active headcount and current base pay by currency. Reports sum that same current base for active employees and group by department, job title, or country, split by currency. They do not add USD to EUR. CSV export is `employee-payroll.csv` plus a grouped file for the open tab (`/api/reports/*`).
- Lists default to 25 rows per page. Any non-API browser route falls back to the SPA shell; unknown `/api`, `/assets` and file requests keep their 404.

How the app was planned is in [docs/openspec-workflow.md](docs/openspec-workflow.md).

## Out of scope

Payroll, tax, banking, FX conversion, SSO, email, realtime collaboration, extra roles, and a permission-admin UI. Reasons are in `REQUIREMENTS.md`.

## Production note

Point `DATABASE_URL` and `SECRET_KEY_BASE` at the hosted Postgres and a real secret. Do not run the assessment seed profiles in production, and do not reuse the local HR password there.
