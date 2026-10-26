# Roles

Everyone is a row on `users`. There is no separate employee or admin table.

| Role | Signs in at | What they can do |
| --- | --- | --- |
| `super_admin` | `/site-admin` | Create, edit, and delete companies and each company's first admin. No company of their own. |
| `company_admin` | `/login` | Everything HR can do, plus register HR users, set the company theme, and see both employees and HR in the directory. |
| `human_resource` | `/login` | Directory, departments, locations, salaries, reports, and password-reset requests for their company. Cannot assign the HR role or change the theme. |
| `employee` | `/login` | Read their own profile, salary history, and this month's payout. Request a password reset. |

In policies, `hr?` means company admin or HR. Only `company_admin?` may set `role` to HR.

An HR user and a company admin can open another HR profile and add that person's salary. They cannot add or change their own salary. Employees cannot write salaries.

Navigation:

- Company admin: Dashboard, Employees, Departments, Locations, Reports, Password resets, Company theme.
- HR: the same list without Company theme.
- Employee: My profile only.
