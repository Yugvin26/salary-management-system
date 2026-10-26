# Performance and indexes

The default seed is about 10,000 employee-role users, each with one current base salary. List and report queries are built for that size, not for loading every row into Ruby.

## Indexes

- Unique email and unique `employee_id` per company, so two companies can reuse an address or an employee ID.
- `users.role`, `users.active`, and `(last_name, first_name)` for the default directory sort and the active filter.
- `users.department_id` and `users.location_id` from the foreign keys, used by department and country filters.
- `locations.country` for country filters and country reports.
- Salaries: one current base per employee (partial unique index on current rows per type). Bonus and commission are stored as history, so they do not take that current slot. `(salary_type, current)` and `effective_on` keep current-base aggregates and this month's payout off a full history scan.
- PaperTrail `versions (item_type, item_id)` for the changelog of one salary line.

## Query shape

- Employee index searches with `ILIKE` on name, email, and employee ID, then `LIMIT`/`OFFSET`. Default page size is 25, maximum 100. The list preloads department, location, and the current base salary so the table is not an N+1.
- Reports `GROUP BY` currency inside department, job title, or country. They read only `current` base rows for active employees.
- CSV export left-joins the current base salary instead of loading every historical line.
- Seed inserts users and salaries with `insert_all` in batches of 1,000 and one shared password digest. PaperTrail is disabled for that bulk load. Edits made in the app after seeding still write versions.
