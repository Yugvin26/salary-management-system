# Employees and HR records

The directory is `/employees`. Lists are 25 rows per page.

## Who appears

- A company admin sees employees and HR in their company, and can filter by All, Employees, or HR.
- An HR user sees both employees and other HR users in their company.
- An employee does not see the directory. Their home page is `/me`.

Search matches name, email, and employee ID. Filters cover department, country, and active, archived, or all. A company admin also filters by All, Employees, or HR. An HR user’s list always includes both roles.

Columns are ID, name, role, email, job title, job type, department, country, and current base. A row opens `/employees/:id`. The register button says "Register user" for a company admin and "Register employee" for HR.

## Registering a user

Company admins and HR can register an employee. Only a company admin can choose the HR role. The password field can generate a 12-character password.

Employee fields: first name, last name, email, password, employee ID, job title, job type, hire date, department, and location.

- Employee ID looks like `E12345` (an `E` and at least five digits). The form can generate one. If an employee is saved without an ID, the server assigns the next one in that company. HR records do not auto-assign an ID.
- Job title can be a preset or a custom value.
- Job type is Remote, Hybrid, or In-office. Flexible was removed. Existing Flexible rows were set to Hybrid.
- Archive sets `active` to false and blocks that person's sign-in. Unarchive restores it.

## HR registration

Choosing HR locks two fields:

- Job title is `HR Partner`.
- Department is the company's department named `HR`, created if it is missing.

Employee ID, job type, hire date, and location stay editable on the form. The server writes the locked job title and department again on save, so a client cannot change them.

## Profile

`/employees/:id` is the staff view of one person. The header shows the name, an Active or Archived badge, and the email, with Edit and Archive or Unarchive. Six facts sit in a grid: employee ID, job title, job type, department, location (office, city, and country), and hire date.

Below that are this month’s payout, salary history, and the add-salary form. Opening your own row hides the form: "You cannot change your own salary. Another HR user or a company admin can add it."

Edit is `/employees/:id/edit`. Leave the password blank to keep the current one. Archive sets `active` to false (`POST /api/employees/:id/archive`). Unarchive sets it back to true. An archived person cannot sign in.

An employee does not open this page. Their own record is `/me`. See [self-profile.md](self-profile.md).
