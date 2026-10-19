---
description: Step 3 — Create one business-logic server action in the _BL module
argument-hint: <ActionName> in <Domain>_BL: <what the business rule does>
---

Create ONE business-logic server action in the `_BL` module. Do only this step —
no CRUD, no service action, no UI.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md (section 3 layers). Work in Development only.
2. The action goes in `[Domain]_BL`. If the request names another module, stop and ask.
3. Use the OutSystems MCP to search `_BL` and `_CS` for actions that already do this
   or part of it. Reuse them; don't duplicate.
4. Dependencies:
   - Write data ONLY by calling `_CS` CRUD actions (`<Entity>_Create`, `_Update`, ...).
     Never use entity actions directly — entities are only in `_CS`.
   - Read data with Aggregates on the `_CS` entities (exposed read-only).
   - May call other `_BL` server actions and server actions from other modules.
   - May call service actions from OTHER domains' `_SL` modules.
   - Never call its own domain's `_SL` (circular reference) and never `_UI`.
   - Add any needed references and tell me which modules were added.
   - If it calls a service action: that call commits on its own and is NOT rolled back
     if this action fails later. Call service actions as the last step when possible,
     or add compensation (undo) logic — and tell me which you chose.
5. Design:
   - Name: verb first, e.g. `Order_Submit`, `Invoice_CalculateTotal`.
   - Public = Yes so `_SL` can call it.
   - Clear inputs/outputs with types; mark mandatory inputs.
   - Validate inputs and business rules first; raise user exceptions with clear messages.
   - Server-action calls share this action's transaction, so an exception rolls them all
     back — use this for all-or-nothing work. Service-action calls are the exception (see above).
   - Use Aggregates for reads; Advanced SQL only if needed — explain why.
   - Log errors using the standard pattern in CLAUDE.md.
6. Show the plan first: module, inputs, outputs, step-by-step flow, every action it calls
   (with its module and whether it is a server or service action), references needed,
   transaction risks, possible errors. Wait for my approval.
7. After approval: create, publish `_BL` to Development, and report what was created.
