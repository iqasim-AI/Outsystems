---
description: Entity — create or edit one entity in a _CS module (data model only, no logic or UI)
argument-hint: create|edit <EntityName> in <Domain>_CS: <attributes, or the changes>
---

# Entity: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — no actions, no screens.
Follow CLAUDE.md and .claude/rules/ (naming, architecture, environments). Work in Development only.

Entities live ONLY in `[Domain]_CS`. If the request names another module, stop and ask.

## Design rules (create and edit)
- Singular PascalCase name; Id is the auto-number primary key.
- Attributes in PascalCase with correct data types and lengths.
- Foreign keys end with `Id`; set the delete rule (Protect by default) and say which you chose.
- Mark mandatory attributes; add sensible default values.
- Audit attributes: CreatedOn, CreatedBy, UpdatedOn, UpdatedBy.
- Indexes for foreign keys and fields used in search or filters.
- Public = Yes, Expose Read Only = Yes (writes go only through `_CS` CRUD actions).
- If a field is a fixed list of values, propose a Static Entity instead of Text.
- Every attribute has a description. Audit attributes use the standard description;
  foreign keys take their description from the referenced entity.

## create
1. Use the OutSystems MCP to inspect the target `_CS` module. If the entity or a similar
   one already exists, stop and tell me (I may want `edit`).
2. Show the plan as a table:
   Attribute | Type | Length | Mandatory | Default | Description | Notes — then wait for my approval.
3. After approval: create the entity, resolve the warnings about it, publish the module
   to Development, and report what was created, the module and the environment.

## edit
Follow `.claude/rules/editing.md`, plus these entity rules:

- **Add an attribute**
  - Mandatory on a table that already has data: give it a Default Value (existing rows
    get it), or add it as optional, fill the existing rows, then make it mandatory.
  - Add its description, and an index if it will be filtered or searched.
- **Change length**: increasing is safe. Decreasing can truncate data: check the longest
  existing value first and report it.
- **Change data type**: do not change it in place. Add a new attribute, migrate the data
  (a timer for large tables), move consumers to it, then mark the old one deprecated.
- **Make an attribute mandatory**: check first that no existing record has it empty.
- **Rename an attribute**: breaking. The database column keeps its old name, but
  Advanced SQL, structures mapped by name and API contracts in consumers break.
- **Delete an attribute**: only with explicit approval. The platform keeps the database
  column but the app can no longer read it. Check every consumer first.
- **Unique index**: check for duplicate values first, or publishing fails.
- **Delete rule change**: explain what happens to child records under the new rule.
- **Static entity**: adding records is safe. Never delete or rename a record that code
  compares against; set the record's built-in `Is_Active` to False instead.
- An entity edit does not change anything else. List the CRUD actions, `_BL` actions,
  screens, blocks and structures that need the change, with the command to run for each
  (`/crud edit`, `/screen edit`, ...).

The plan uses the same table as `create`, with a Change column (Added / Changed / Removed)
and the old value next to the new one.
