# CLAUDE.md — OutSystems Team Guide

> Shared instructions for Claude Code. Every developer's Claude reads this file.
> Keep it short and specific. Update via pull request. Owner: [NAME]

## 1. About this team
- Team of 22 developers building on OutSystems 11 (Reactive Web).
- Tenant: `https://[YOUR-TENANT]` (MCP connection is in `.mcp.json`).
- Business language: [English / Arabic]. UI labels must support [RTL / LTR].

## 2. Rules
The detailed rules are in `.claude/rules/`. Read the one that matches your task:

| File | Covers |
|---|---|
| `environments.md` | Dev / QA / Pre-Production / Production — what Claude may do in each |
| `architecture.md` | Module layers, who may call whom, transactions |
| `naming.md` | Modules, entities, attributes, actions, screens, REST |
| `coding.md` | Aggregates, pagination, validation, exceptions |
| `security-roles.md` | Roles, secrets, hard-coded values |
| `testing.md` | BDDFramework unit tests — what to test, test data, test users, when to run |
| `docs/lld/README.md` | LLD documents — Word export, Confluence publishing, setup |
| `editing.md` | Changing existing elements — impact check, breaking changes, publish order |
| `ui-design.md` | UI consistency, responsive design, RTL/LTR, accessibility |
| `ui-theme-reference.md` | Verified Infath theme fonts, variables, selectors, and known CSS risks |
| `ui-customization.md` | CSS scoping, cascade safety, and safe theme customization |
| `review.md` | Reviewing a story's implementation — ticket gaps, layers, external services, DB hits, files, UI |
| `notifications.md` | Notification templates — naming, Excel columns, channels, Id, timer, how to send |
| `never-do.md` | Hard limits and lessons learned |

Always work in Development only. Confirm the target environment before any publish or deploy.

For UI work, use `/ui-change` for a focused change, `/ui-review` for review-only feedback, and `/ui-modernize` for a visual refresh that preserves behaviour. These supplement `/block` and `/screen`; they do not replace them.

Mandatory Infath UI conventions are documented in `.claude/rules/ui-design.md` and `.claude/rules/ui-theme-reference.md`: no inline styles, semantic theme colors, upload/popup/table/expression classes, and the portal-only `Infath_LSGTheme` layout/theme conventions. For External portal page structure, follow `.claude/commands/screen.md`.

## 3. Integrations
- REST APIs consumed: [name — purpose — module]
- Exposed APIs: [name — consumer]
- External systems: [ERP / SSO / payment gateway, etc.]

## 4. Working with Claude
- Before a large change, show a short plan and wait for approval.
- After publishing, report: what changed, which module, which environment.
- When something is unclear in the rules, ask — don't guess.
