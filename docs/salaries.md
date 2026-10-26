# Salaries

A salary line belongs to an employee or an HR user. Company admins and other company admins cannot be paid through this screen. Amounts are stored as `amount_cents` with a three-letter currency. There is no currency conversion.

## Who can add a line

A company admin or an HR user can add a line for an employee or for a different HR user in the same company.

They cannot add or change their own salary. The profile hides the form and `POST /api/employees/:id/salaries` returns: "You cannot change your own salary."

An employee can read their own lines and cannot create one.

## Base, bonus, and commission

- **Base** is the yearly amount. A new current base marks the previous current base as history. That is the yearly or twice-a-year increment. PaperTrail records both the new line and the update that cleared `current` on the old line.
- **Bonus** and **commission** are one-month payouts. They are saved with `current` false even if the form asks for current. They do not replace the current base, and they do not replace an earlier bonus or commission. Each one is history immediately, with a PaperTrail create version.

All of a person's lines must use the same currency as their first line.

The history table shows effective date, type, amount, and whether the line is the current base or history.
