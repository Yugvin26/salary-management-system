# Companies

Each company is a tenant. Users, departments, locations, salaries, and password-reset requests belong to one company. A super admin has no company.

## Who manages companies

Only a super admin, on `/site-admin`.

- Create, rename, and delete a company from a modal.
- Creating a company also creates its theme settings and one company admin. The admin password can be typed or generated in the form. Leave the password blank when editing a company to keep the current one.
- Deleting a company removes its users, salaries, salary versions, departments, locations, and password-reset requests.

Company names are unique, ignoring case.

## What stays inside a company

- Email is unique per company, not globally.
- Employee ID is unique per company.
- Department name and location name are unique per company.
- A user's department and location must belong to that user's company.
- HR and company admins only see people, salaries, departments, locations, reports, and password-reset requests in their own company.
