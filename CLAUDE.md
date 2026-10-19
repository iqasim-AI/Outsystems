# CLAUDE.md — OutSystems Team Guide

> Shared instructions for Claude Code. Every developer's Claude reads this file.
> Keep it short and specific. Update via pull request. Owner: [NAME]

## 1. About this team
- Team of 5 developers building on OutSystems [ODC / O11 — pick one].
- Tenant: `https://[YOUR-TENANT]` (MCP connection is in `.mcp.json`).
- Main apps we work on:
  - [App name] — [one-line purpose]
  - [App name] — [one-line purpose]
- Business language: [English / Arabic]. UI labels must support [RTL / LTR].

## 2. Environments — read carefully
| Environment | Purpose | Claude may… |
|---|---|---|
| Development | Daily work | Edit, publish |
| Test / QA | Testing | Read only — ask before deploying |
| Production | Live users | **Never edit, publish or deploy** |

- Always confirm the target environment before any publish or deploy.
- If unsure which environment you are in, stop and ask.

## 3. Architecture
- Each domain is split into these modules (top calls down, never up):

| Layer | Module | Contains | May call |
|---|---|---|---|
| UI | `[Domain]_UI` | Screens, blocks, client actions | `_SL` service actions [confirm: also `_BL`?] |
| Service | `[Domain]_SL` | Service actions (public API of the domain) | `_SL` of other domains, `_BL`, `_CS` server actions |
| Logic | `[Domain]_BL` | Business-logic server actions | `_CS` CRUD actions, other `_BL`, server actions of other modules, `_SL` service actions of OTHER domains |
| Core | `[Domain]_CS` | Entities, static entities, CRUD server actions | Foundation only |
| Foundation | `_IS`, `_Th`, libs | Integrations, theme, utilities | — |

- Entities and CRUD live ONLY in `_CS`. No other module writes to entities directly.
- Business rules live ONLY in `_BL`. They write data by calling `_CS` CRUD actions.
- A `_BL` action may call server actions from other modules and service actions from
  OTHER domains' `_SL`. It must never call its own domain's `_SL` (that `_SL` already
  references this `_BL` — it would be circular).
- When `_BL` calls a service action, that call commits on its own: if the `_BL` action
  fails afterwards, the service action's changes are NOT rolled back. Call service actions
  last, or add compensation (undo) logic.
- Service actions live ONLY in `_SL`. They are thin: call `_BL` / `_CS` / other `_SL`, no business rules.
- A service action may call another service action or a server action from a different module.
  Each service action runs in its own transaction: if one call commits and a later one fails,
  the first is NOT rolled back. For multi-step writes that must be all-or-nothing, put them
  in one `_BL` server action instead, or add compensation logic.
- Never create circular references between modules.
- Shared libraries: [list e.g. Common_Lib, Theme_Lib]

## 4. Naming conventions
- Modules: `[Domain]_[Layer]` (e.g. `Customer_CS`, `Customer_BL`, `Customer_SL`, `Customer_UI`)
  - Suffixes: `_CS` core/CRUD, `_BL` business logic, `_SL` service layer, `_UI` end-user, `_IS` integration, `_Th` theme
- Entities: singular, PascalCase (`Customer`, `OrderItem`)
- Attributes: PascalCase; foreign keys end with `Id` (`CustomerId`)
- Server actions: verb first (`Customer_Create`, `Order_GetById`)
- Client actions: prefix with `On` for events (`OnSaveClick`)
- Screens: PascalCase noun (`CustomerList`, `CustomerDetail`)
- Static entities: plural (`OrderStatuses`)

## 5. Coding rules
- Use Aggregates first; use Advanced SQL only when an aggregate can't do it, and explain why.
- Always paginate list screens (default page size: [20]).
- Validate input on the server, not only on the client.
- Handle exceptions with our standard pattern: [describe, e.g. log + user-friendly message].
- Use roles for access: [list roles]. Every screen must check a role.
- No hard-coded URLs, keys or credentials — use Site Properties / Settings.
- Reuse existing actions before creating new ones; search first.

## 6. Integrations
- REST APIs consumed: [name — purpose — module]
- Exposed APIs: [name — consumer]
- External systems: [ERP / SSO / payment gateway, etc.]

## 7. Working with Claude
- Before a large change, show a short plan and wait for approval.
- After publishing, report: what changed, which module, which environment.
- Prefer small, incremental changes over one big change.
- When something is unclear in this file, ask — don't guess.

## 8. Never do
- Never publish or deploy to Production.
- Never delete entities, attributes or data without explicit approval.
- Never change shared Foundation modules without telling the team.
- Never put secrets in this repo or in prompts.

## 9. Lessons learned
<!-- Add a line each time Claude gets something wrong. Newest on top. -->
- [YYYY-MM-DD] [Rule learned] — added by [name]
