# How this app was planned

The behavior and task list were written with OpenSpec before implementation. The planning record lives next to this app:

`../openspec/changes/build-salary-management-system`

That change has the proposal, spec deltas (authentication, authorization, directory, salary history, org structure, reporting, seeding), design notes, and the task checklist. Specs in the parent `openspec/specs` directory stay empty until that change is archived.

The implementation followed those artifacts: Rails monolith, cookie session, one `users` table, Pundit, PaperTrail on salaries, compose plus Foreman, and a React SPA under `app/javascript/components/`.
