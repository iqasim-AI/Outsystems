---
description: Step 1 — Create one OutSystems entity (data model only, no logic or UI)
argument-hint: <EntityName> in <Module>, attributes: <list>
---

Create ONE OutSystems entity. Do only this step — no actions, no screens.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md (naming, layers, environments). Work in Development only.
2. Use the OutSystems MCP to inspect the target Core module first. If the entity
   or a similar one already exists, stop and tell me.
3. Entity design:
   - Singular PascalCase name; Id is the auto-number primary key.
   - Attributes in PascalCase with correct data types and lengths.
   - Foreign keys end with `Id`; set the delete rule (Protect by default) and say which you chose.
   - Mark mandatory attributes; add sensible default values.
   - Add audit attributes: CreatedOn, CreatedBy, UpdatedOn, UpdatedBy.
   - Add indexes for foreign keys and fields used in search or filters.
   - Public = Yes, Expose Read Only = Yes (writes go only through CRUD actions).
   - If a field is a fixed list of values, propose a Static Entity instead of Text.
4. Show the plan first as a table:
   Attribute | Type | Length | Mandatory | Default | Notes — then wait for my approval.
5. After approval: create the entity, publish the module to Development, and report
   what was created, the module, and the environment.
