# My profile

An employee’s home is `/me`. The nav has only "My profile". `GET /api/profile` returns that person, their salary lines, and this month’s payout.

The page shows name, email, employee ID, job title, job type, department, location, and hire date. Salary history is read-only: there is no add form and no Versions button. The status column says whether a line is the current base or history.

This month’s payout uses the same rules as a staff profile. See [monthly-payout.md](monthly-payout.md).

Company admins and HR do not use this page for their own record. They open themselves from the directory, where the salary form is hidden. See [employees.md](employees.md).
