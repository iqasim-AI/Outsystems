---
description: Step 6 — Create one screen (list or detail) using existing blocks and actions
argument-hint: <ScreenName> in <UIModule>, type: list|detail, for <Entity>
---

Create ONE screen. Do only this step — reuse existing blocks and server actions;
don't create new logic.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md. Work in Development only.
2. Use the OutSystems MCP to check the UI module, existing screens, blocks, and the
   Core actions for this entity. If a needed block or action is missing, stop and tell
   me which command to run first (`/create-crud`, `/create-block`, ...).
3. Screen design:
   - Name: PascalCase noun, e.g. `CustomerList`, `CustomerDetail`.
   - Set the allowed roles (from CLAUDE.md) — no anonymous access unless I say so.
   - Use the app's layout and menu; add a menu entry if it's a main screen.
4. List screen:
   - Aggregate with only the needed attributes; search box and filters.
   - Pagination (page size from CLAUDE.md), sorting on main columns.
   - Empty state message; "New" button to the detail screen; delete with confirmation.
5. Detail screen:
   - Input parameter `<Entity>Id` (NullIdentifier = new record).
   - Use the existing form block if there is one; otherwise build the form.
   - Save calls `<Entity>_CreateOrUpdate`; show success/error feedback; go back to the list.
6. Show the plan first: screen type, inputs, data fetched, widgets, roles, navigation.
   Wait for my approval.
7. After approval: create, publish to Development, and report the screen URL.
