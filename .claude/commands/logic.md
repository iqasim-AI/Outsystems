---
description: Logic — create or edit one business-logic server action in the _BL module
argument-hint: create|edit <ActionName> in <Domain>_BL: <the business rule, or the change>
---

# Logic: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — no CRUD, no service action, no UI.
Follow CLAUDE.md and .claude/rules/ (see `architecture.md` for the layers). Work in Development only.

The action lives in `[Domain]_BL`. If the request names another module, stop and ask.

## Design rules (create and edit)
- **What it may call** (from `architecture.md`):
  - Own domain's `_CS`: CRUD actions for writes, Aggregates on its entities for reads.
    Never use entity actions directly.
  - Other actions in the same `_BL` module.
  - Other domains' `_SL` service actions, **only downward in the domain dependency order**.
  - Foundation modules (`_IS` wrappers, libraries).
  - Never its own domain's `_SL` (circular), never `_UI`, never `_API`, never another
    domain's `_BL` or `_CS` directly.
  - Check every new reference against the checklist in `architecture.md` and tell me
    which modules were added.
- **Transactions**:
  - Server-action calls share this action's transaction, so an exception rolls them all
    back. Use this for all-or-nothing work.
  - A service-action call commits on its own and is NOT rolled back if this action fails
    later. Call service actions as the last step when possible, or add compensation (undo)
    logic, and tell me which you chose.
- Name: verb first, e.g. `Order_Submit`, `Invoice_CalculateTotal`.
- Public = Yes so `_SL`, `_UI` and `_API` of the same domain can call it.
- Clear inputs/outputs with types; mark mandatory inputs. Every element has a description.
- Validate inputs and business rules first; raise User Exceptions with clear messages.
- Aggregates for reads; Advanced SQL only if needed — explain why. No queries or service
  actions inside loops.
- Log errors as described in `.claude/rules/coding.md`.

## Standard save and delete
Every entity that a screen or block writes to has these two actions in `_BL`, so the UI
never calls `_CS` CRUD directly. When the request is just `<Entity>_Save` or
`<Entity>_Delete` with no extra rules, build exactly this:
- `<Entity>_Save` — input: Entity record; output: Id.
  Check the role → validate mandatory fields and formats → apply the business rules the
  request lists (if any) → call `<Entity>_CreateOrUpdate` (`_CS`) → return the Id.
- `<Entity>_Delete` — input: Id.
  Check the role → check the record exists and may be deleted (e.g. status rules the
  request lists) → call `<Entity>_Delete` (`_CS`).
Both raise User Exceptions with clear messages for every rule they reject.

## create
1. Use the OutSystems MCP to search `_BL` and `_CS` for actions that already do this or
   part of it. Reuse them; don't duplicate. If the same action exists, stop (I may want `edit`).
2. Show the plan: module, inputs, outputs, step-by-step flow, every action it calls (with
   its module and whether it is a server or service action), references needed,
   transaction risks, possible errors. Wait for my approval.
3. After approval: create, publish `_BL` to Development, and report what was created.
   End the report with the `/test create` command to run next.

## edit
Follow `.claude/rules/editing.md`, plus these logic rules:

- **Callers**: list every caller (`_SL` actions, screens and blocks in `_UI`, `_API`
  methods, timers) and say whether the new behaviour is right for each one. If it is
  right for some and wrong for others, create a new action instead of changing this one.
- **Signature**: adding an optional input or a new output is safe. Removing, renaming,
  retyping or making an input mandatory is breaking — follow `editing.md`.
- **Behaviour changes with the same signature** (new rule, stricter check, different
  result) still count as breaking if callers rely on the old result. Say so in the plan.
- **New calls**: check each new reference against `architecture.md`. A new service-action
  call means re-checking where it sits in the flow and whether compensation is needed.
- **Reordering steps**: say how it changes what is rolled back on failure.
- The plan shows the flow before and after, with the changed steps marked.
- If the action has tests (`<ActionName>_Tests` in `[Domain]_Tests`), end the report with
  the `/test edit` command to run next, listing the rules that changed.
