# Salary versions

PaperTrail versions exist only for `salaries`. Bulk seeding turns versioning off. Changes made in the app after that are versioned, including who did it (`whodunnit`).

`GET /api/salaries/:salary_id/versions` is limited to salaries in the signed-in user's company. The profile **Versions** button loads that list, 25 rows per page.

Each version row shows:

- Type (`base`, `bonus`, or `commission`), including on an update that only changed `current`
- Amount, when that version recorded one
- Created at and updated at
- Actor name, or Unknown when the author was not stored

A new base therefore has two visible stories: a create version on the new line, and an update version on the previous line when it stopped being current. A bonus or commission has a create version and stays in history.
