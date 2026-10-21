---
description: Service action — create or edit one service action in the _SL module (the domain's contract for other domains and apps)
argument-hint: create|edit <ServiceActionName> in <Domain>_SL: <what it calls, or the change>
---

# Service action: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — no business rules, no CRUD, no UI.
Follow CLAUDE.md and .claude/rules/ (see `architecture.md` for the layers). Work in Development only.

The service action lives in `[Domain]_SL`. If the request names another module, stop and ask.
Service actions are for **other domains and other apps**. Inside the same domain, callers
use the `_BL` server action directly.

## Design rules (create and edit)
- **What it may call** (from `architecture.md`):
  - Own domain's `_BL` server actions — the normal case.
  - Own domain's `_CS` actions (e.g. `<Entity>_GetById`) for simple reads with no rules.
  - Other domains' `_SL` service actions, **only downward in the domain dependency order**.
  - Foundation modules.
  - Never `_UI`, never `_API`, never another domain's `_BL` or `_CS`, never a module that
    references this `_SL`. Add the needed references and list them for me.
- **Keep it thin**: orchestration only, no business rules. If rules are needed, tell me
  to put them in `_BL` first (`/logic create` or `/logic edit`).
- Inputs/outputs use simple types or Structures, never Entity records. Create a Structure
  if needed (e.g. `OrderDto`) in `_SL`.
- Check authorization inside — don't trust the caller.
- Return: Success (Boolean), ErrorMessage (Text), and the data. Catch exceptions and
  return them in ErrorMessage.
- **Transactions**: each service action runs in its OWN transaction and commits when it
  finishes. If it calls another service action and a later step fails, the earlier call
  is NOT rolled back. Tell me if this creates a consistency risk, and suggest moving the
  steps into one `_BL` action or adding compensation (undo) logic.
- Not called in loops or for fine-grained reads (see `architecture.md`).

## create
1. Use the OutSystems MCP to read every action it will call. If one doesn't exist, stop
   and tell me which command to run first (`/crud create` or `/logic create`).
   If the same service action exists, stop (I may want `edit`).
2. Show the plan: module, inputs, outputs, structures, every action it calls (with its
   module), references needed, transaction risks. Wait for my approval.
3. After approval: create, publish `_SL` to Development, and report which modules can consume it.

## edit
Follow `.claude/rules/editing.md`, plus these service action rules:

- **Consumers you can't see**: service actions are called from other domains and apps
  with their own release cycles. Assume consumers exist beyond those the MCP shows.
- **Never break the contract in place.** Allowed in place: add an optional input with a
  default, add an output, add a field to an output structure, change internals with the
  same meaning.
- **Anything else** (rename, remove, retype, new mandatory input, different meaning):
  create `<Name>_V2` next to it, mark the old one `Deprecated: use <Name>_V2` in its
  description, and keep it working until all consumers have moved.
- A breaking change to a service action shows up **at runtime** in consumers that were
  not republished, not as an error in Service Studio. Never rely on TrueChange to find it.
- **Changes to the logic it calls** belong in `_BL` (`/logic edit`). Edit the service
  action only for its contract or orchestration.
- The report lists the consumers that must be told about a new version.
