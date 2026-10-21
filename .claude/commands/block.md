---
description: Block — create or edit one UI block (e.g. a form or a card)
argument-hint: create|edit <BlockName> in <Module> for <Entity>: <what it shows/does, or the change>
---

# Block: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — no screen, no new server logic.
Follow CLAUDE.md and .claude/rules/. Work in Development only.

## Where the block lives (from `architecture.md`)
- Used only by screens in one `_UI` module → that `[Domain]_UI` module.
- Reused across modules and business-aware (e.g. a beneficiary summary card) → `[Domain]_CW`.
- Reused and business-agnostic (generic UI pattern) → a Foundation pattern library.
- Never reuse a block from another `_UI` module. If unsure where it belongs, ask.

## Design rules (create and edit)
- Name: PascalCase noun, e.g. `CustomerForm`, `CustomerCard`.
- Inputs: only what the block needs (e.g. `CustomerId` or a record). Keep it small.
- Events notify the parent instead of navigating, e.g. `OnSaved`, `OnCancel`.
- Client actions start with `On` (e.g. `OnSaveClick`).
- Reads: Aggregates on `_CS` entities (read-only), with Max Records set.
- Writes: call the own domain's `_BL` server action (other domains: their `_SL`). Never call
  `_CS` CRUD actions from a block, and no business logic in the block.
- A Foundation pattern block has no data access at all: it takes inputs and raises events.
- One server call per user event (see `coding.md`).
- Show validation messages and a loading state; disable Save while saving.
- Labels support the language and direction stated in CLAUDE.md. Responsive for desktop and mobile.
- Reuse the theme: use existing classes; don't invent new CSS if the theme has a class for it.

## create
1. Use the OutSystems MCP to check existing blocks and the theme first. If the same block
   exists, stop (I may want `edit`). If a `_BL` action it needs is missing, stop and tell me
   to run `/logic create` first.
2. Show the plan: module, inputs, events, widgets/layout, actions it calls. Wait for my approval.
3. After approval: create, publish to Development, and report how to use it in a screen.

## edit
Follow `.claude/rules/editing.md`, plus these block rules:

- **Where used**: list every screen and block that uses it (in its own module, and in
  other modules if it lives in `_CW` or a library). A visual or behaviour change appears
  in all of them — say so in the plan.
- **Inputs**: adding an optional input with a default is safe. Adding a mandatory input,
  or removing, renaming or retyping one, breaks every parent — list them.
- **Events**: removing or renaming an event, or changing its parameters, breaks every
  parent that handles it. Adding a new event is safe.
- **Moving the block** (e.g. from `_UI` to `_CW` because another module needs it): create
  it in the new module, switch the parents to it, then remove the old one after approval.
- **New data writes**: go through `_BL`. If the action is missing, stop and tell me to run
  `/logic create` or `/logic edit` first.
