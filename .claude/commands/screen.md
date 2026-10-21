---
description: Screen — create or edit one screen (list or detail) using existing blocks and actions
argument-hint: create|edit <ScreenName> in <Domain>_UI[, type: list|detail, for <Entity>]: <details, or the change>
---

# Screen: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — reuse existing blocks and server
actions; don't create new logic. Follow CLAUDE.md and .claude/rules/. Work in Development only.

Screens live in `[Domain]_UI`. If the request names another module, stop and ask.

## Design rules (create and edit)
- Name: PascalCase noun, e.g. `CustomerList`, `CustomerDetail`.
- Set the allowed roles (from `.claude/rules/security-roles.md`) — no anonymous access
  unless I say so.
- Use the app's layout and menu; add a menu entry if it's a main screen.
- **Reads**: Aggregates on `_CS` entities (read-only, own or other domains) with only the
  needed attributes and Max Records set. Don't route simple reads through service actions.
- **Writes**: call the own domain's `_BL` server action (other domains: their `_SL`).
  Never call `_CS` CRUD actions from a screen.
- One server call per user event (see `coding.md`).
- Links to screens in other `_UI` modules are allowed; reusing their blocks or actions is not.
- **List screen**: search box and filters; pagination (page size from `coding.md`); sorting on
  main columns; empty state message; "New" button to the detail screen; delete with confirmation.
- **Detail screen**: input parameter `<Entity>Id` (NullIdentifier = new record); use the
  existing form block if there is one, otherwise build the form; Save calls the `_BL` save
  action (e.g. `<Entity>_Save`); show success/error feedback; go back to the list.

## create
1. Use the OutSystems MCP to check the `_UI` module, existing screens and blocks, and the
   `_BL` actions for this entity. If the same screen exists, stop (I may want `edit`).
   If a needed block or action is missing, stop and tell me which command to run first
   (`/block create`, `/logic create`, ...).
2. Show the plan: screen type, inputs, data fetched, widgets, roles, navigation. Wait for my approval.
3. After approval: create, publish to Development, and report the screen URL.

## edit
Follow `.claude/rules/editing.md`, plus these screen rules:

- **Who links to it**: list the screens, menus and other `_UI` modules that navigate to
  this screen.
- **Input parameters**: adding an optional one is safe. Adding a mandatory one, or
  removing, renaming or retyping one, breaks every link to the screen — list them.
- **Renaming the screen** changes its URL: links from other modules, bookmarks and URLs
  sent in emails or notifications break. Breaking change.
- **Roles**: say exactly who gains or loses access, and wait for approval.
- **Data changes** (new columns, filters): keep Max Records, pagination and the
  no-queries-in-loops rule. New writes go through `_BL`.
- **New behaviour that needs logic**: stop and tell me to run `/logic create` or
  `/logic edit` first. No business logic in the screen.
- **A change to a shared block** belongs in `/block edit`, not here.
