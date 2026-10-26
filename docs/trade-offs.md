# Trade-offs

## Cookies instead of JWT

The SPA is served by Rails on the same origin as `/api`. After sign-in, the browser already has a first-party context, so an `HttpOnly` `SameSite=Lax` session cookie is enough. React does not store a token. Logout destroys the session. XSS cannot read the cookie. Mutating requests still send a CSRF token.

JWT fits a separately hosted frontend, mobile clients, or third-party API consumers. That needs a bearer token on every call, a logout blacklist or short expiry, and a place to keep the token. `localStorage` is readable by XSS. None of that improves this HR workflow.

## One User table instead of a separate Employee table

Login, registration, and the directory are the same person. A second `employees` table would isolate HR accounts, but it would also force a join for every “who is this employee” question and a second place to disable access. Role plus Pundit answers the same product rule: a company admin or HR user manages the org, and an employee sees only their row. The super admin is the same table with no company.

## Pundit instead of scattered role checks

Policies name the action (`index?`, `create?`, `archive?`) and are unit-tested without rendering a page. Controllers call `authorize` and `policy_scope`. Adding a third role later means editing policies, not hunting through controllers.
