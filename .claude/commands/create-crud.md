---
description: Step 2 — Create CRUD server actions for an existing entity
argument-hint: <EntityName> in <Module>
---

Create the CRUD server actions for ONE existing entity. Do only this step —
no business rules, no service actions, no UI.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md. Work in Development only.
2. Use the OutSystems MCP to read the entity first. If it doesn't exist, stop and tell me.
   If any of these actions already exist, list them and ask before changing.
3. Create these server actions in the `[Domain]_CS` module (same module as the entity),
   in a folder named after the entity. No business rules here — those go in `_BL`:
   - `<Entity>_Create` — input: Entity record; output: Id
   - `<Entity>_Update` — input: Entity record
   - `<Entity>_CreateOrUpdate` — input: Entity record; output: Id
   - `<Entity>_Delete` — input: Id
   - `<Entity>_GetById` — input: Id; output: Entity record (use an Aggregate)
4. Inside every write action:
   - Check the user's role (use the roles in CLAUDE.md) before any change.
   - Validate mandatory fields; raise a clear user exception if invalid.
   - Set audit fields: CreatedOn/CreatedBy on create, UpdatedOn/UpdatedBy on update.
   - Delete: check the record exists; respect delete rules; never delete without the Id.
5. Set Public = Yes so other modules can use them. Add a description to each action.
6. Show the list of actions with inputs/outputs first and wait for my approval.
7. After approval: create, publish to Development, and report what was created.
