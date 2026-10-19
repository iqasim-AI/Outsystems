---
description: Step 4 — Create one Service Action in the _SL module (calls _BL, _CS or other _SL)
argument-hint: <ServiceActionName> in <Domain>_SL calling <actions/modules>
---

Create ONE Service Action in the `_SL` module. Do only this step —
no business rules, no CRUD, no UI.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md (section 3 layers). Work in Development only.
2. The service action goes in `[Domain]_SL`. If the request names another module, stop and ask.
3. Use the OutSystems MCP to read every action it will call. If one doesn't exist,
   stop and tell me which command to run first (`/create-crud` or `/create-logic`).
4. What it may call:
   - `_BL` server actions (business logic) — the normal case.
   - `_CS` server actions (e.g. `<Entity>_GetById`) for simple reads/writes with no rules.
   - Service actions in other domains' `_SL` modules.
   - Server actions from other domains' modules, if the request says so.
   - Never `_UI`. Never a module that references this `_SL` (no circular references).
   - Add the needed references and list them for me.
5. Keep it thin:
   - No business rules here — orchestration only. If rules are needed, tell me to
     create them in `_BL` first.
   - Inputs/outputs use simple types or Structures, never Entity records.
     Create a Structure if needed (e.g. `OrderDto`) in `_SL`.
   - Check authorization inside — don't trust the caller.
   - Return: Success (Boolean), ErrorMessage (Text), and the data.
   - Catch exceptions and return them in ErrorMessage.
6. Transactions — important:
   - Each service action runs in its OWN transaction and commits when it finishes.
   - If it calls another service action and a later step fails, the earlier call is NOT
     rolled back. Tell me if this creates a consistency risk, and suggest either moving
     the steps into one `_BL` action or adding compensation (undo) logic.
7. Show the plan first: module, inputs, outputs, structures, every action it calls
   (with its module), references needed, transaction risks. Wait for my approval.
8. After approval: create, publish `_SL` to Development, and report which modules can consume it.
