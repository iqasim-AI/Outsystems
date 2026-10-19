# CLAUDE.md — OutSystems Team Guide

> Shared instructions for Claude Code. Every developer's Claude reads this file.
> Keep it short and specific. Update via pull request. Owner: [NAME]

## 1. About this team
- Team of 5 developers building on OutSystems [O11 — pick one].
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
- We follow the OutSystems layered architecture:
  - **Foundation** — reusable, non-business (themes, connectors, utilities)
  - **Core** — business entities and logic
  - **End-user** — screens and UI flows
- Upper layers may reference lower layers only. Never the reverse.
- No business logic in End-user modules; put it in Core server actions.
- Shared libraries: [list e.g. Common_Lib, Theme_Lib]

## 4. Naming conventions
- Modules: `[Domain]_[Layer]` (e.g. `Customer_CS`, `Customer_UI`)
  - Suffixes: `_CS` core services, `_UI` end-user, `_IS` integration, `_Th` theme
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
