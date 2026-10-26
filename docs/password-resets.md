# Password resets

`/forgot-password` is public. `POST /api/password_resets` looks up the email across companies, excluding super admins.

| Match | What happens |
| --- | --- |
| One company admin or HR user, password omitted | `{ result: "staff" }`. The form then asks for a new password. |
| One company admin or HR user, with a password | The password is saved. `{ result: "reset" }`. |
| One employee | A pending `PasswordResetRequest` is created. The password does not change. `{ result: "requested" }`. |
| More than one company | The email is ambiguous. The person is told to contact their company admin. |
| Super admin or unknown email | Reset is unavailable. |

An employee cannot complete their own reset. Company admins and HR see requests on `/password-resets`, 25 per page, only for their company. Each pending row starts with a generated password that can be edited. Saving it marks the request completed and shows "Password updated for …". Share that password with the employee. The app does not email it. Only one pending request is kept per user. Completed rows stay on the list without a password field.
