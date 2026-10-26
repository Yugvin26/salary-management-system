# Departments and locations

Company admins and HR manage both lists at `/departments` and `/locations`. Employees cannot.

- A department has a name, unique in the company without regard to case.
- A location has a name, city, and country. The name is unique in the company.
- Both lists are 25 rows per page. The screens add and delete. `PATCH` can still rename a department, or change a location’s name, city, or country.
- Delete is refused while anyone is assigned, with "Employees are still assigned".
- A person can only be assigned a department or location from their own company.
- Country is used by the country pay report. The salary form also picks a default currency from the location country when the person has no salary yet (United States USD, United Kingdom GBP, Germany EUR, India INR, Brazil BRL).
