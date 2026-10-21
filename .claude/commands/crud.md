---
description: CRUD — create or edit the CRUD server actions of one entity in its _CS module
argument-hint: create|edit <EntityName> in <Domain>_CS[: <changes or extra actions>]
---

# CRUD: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — no business rules, no service
actions, no UI. Follow CLAUDE.md and .claude/rules/. Work in Development only.

## Design rules (create and edit)
- CRUD actions live in the `[Domain]_CS` module that owns the entity, in a folder named
  after the entity. No business rules here — those go in `_BL`.
- Standard actions:
  - `<Entity>_Create` — input: Entity record; output: Id
  - `<Entity>_Update` — input: Entity record
  - `<Entity>_CreateOrUpdate` — input: Entity record; output: Id
  - `<Entity>_Delete` — input: Id
  - `<Entity>_GetById` — input: Id; output: Entity record (use an Aggregate)
- Inside every write action:
  - Check the user's role (roles in `.claude/rules/security-roles.md`) before any change.
  - Validate mandatory fields; raise a clear User Exception if invalid.
  - Set audit fields: CreatedOn/CreatedBy on create, UpdatedOn/UpdatedBy on update.
  - Delete: check the record exists; respect delete rules; never delete without the Id.
- Public = Yes so `_BL` and `_SL` can use them. `_UI` and `_API` never call them
  directly (see `architecture.md`). Every action has a description.

## create
1. Use the OutSystems MCP to read the entity first. If it doesn't exist, stop and tell me
   to run `/entity create`. If any of these actions already exist, list them and ask
   (I may want `edit`).
2. Show the list of actions with inputs/outputs and wait for my approval.
3. After approval: create, publish to Development, and report what was created.

## edit
Follow `.claude/rules/editing.md`, plus these CRUD rules:

- **After an entity edit** (the usual reason): add validation for new mandatory
  attributes, and remove validation for attributes that were removed.
- **Add a missing standard action or a new read action** (e.g. `<Entity>_GetByRequestId`):
  create it with the design rules above. This is non-breaking.
- **Change validation**: stricter validation is breaking for every caller that sends the
  now-invalid data. List the callers (`_BL`, `_SL` actions) and say which are affected.
- **Change a signature**: CRUD inputs are the entity record, so attribute changes flow
  through without a signature change. Any other input or output change follows the
  breaking-change rules.
- **Business rules requested here**: stop and tell me to put them in `_BL`
  (`/logic create` or `/logic edit`).
