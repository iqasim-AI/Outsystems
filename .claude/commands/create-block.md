---
description: Step 5 — Create one reusable UI block (e.g. a form or a card)
argument-hint: <BlockName> in <UIModule> for <Entity>: <what it shows/does>
---

Create ONE reusable block. Do only this step — no screen, no new server logic.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md and .claude/rules/. Work in Development only. Blocks live in the End-user (UI) module
   or a shared UI library if reused across apps — ask me which.
2. Use the OutSystems MCP to check existing blocks and the theme first. Reuse patterns
   and styles; don't invent new CSS if the theme has a class for it.
3. Design:
   - Name: PascalCase noun, e.g. `CustomerForm`, `CustomerCard`.
   - Inputs: what the block needs (e.g. `CustomerId` or a record). Keep it small.
   - Events: notify the parent instead of navigating, e.g. `OnSaved`, `OnCancel`.
   - Client actions start with `On` (e.g. `OnSaveClick`).
   - Data writes call the Core CRUD/logic server actions — no logic in the block.
   - Show validation messages and a loading state; disable Save while saving.
   - Labels support [English/Arabic] and RTL as stated in CLAUDE.md.
   - Responsive for desktop and mobile.
4. Show the plan first: inputs, events, widgets/layout, actions it calls.
   Wait for my approval.
5. After approval: create, publish to Development, and report how to use it in a screen.
