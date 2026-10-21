---
description: Story — turn one user story into the ordered list of team commands to run one by one (read-only, builds nothing)
argument-hint: <Feature name> in <Domain>: <user story and acceptance criteria>
---

# Story: from user story to commands

User story: $ARGUMENTS

Turn this user story into the list of team commands the developer will run **one by one**
(`/entity`, `/crud`, `/logic`, `/service-action`, `/api-consume`, `/api-expose`, `/block`,
`/screen`). Follow CLAUDE.md and .claude/rules/.

**This command builds nothing.** Use the OutSystems MCP only to read. Do not create, change
or publish anything.

## Step 1: read what exists
Use the OutSystems MCP to inspect the domain's modules (`_CS`, `_BL`, `_SL`, `_UI`, `_API`,
`_CW`) and any module the story mentions:
- entities, static entities and attributes that already cover part of the story
- `_BL` actions, blocks and screens that already exist
- roles in `.claude/rules/security-roles.md`

Everything that exists is reused or changed with `edit`, never created again.

## Step 2: ask before designing
If the story leaves something open that changes the design (who can do what, status flow,
mandatory fields, what happens after submit), ask **all** the questions at once, in one
message. Do not guess. Smaller gaps become listed assumptions in step 3.

## Step 3: design from the screen backwards
Show, in this order:

1. **Screen spec** — one row per screen:
   Screen | Type (list/detail/popup) | Data shown | Filters/search | Buttons | Roles
2. **What it needs underneath** — one row per element:
   Layer | Module | Element | New or Edit | Why (which screen need it serves)
   Derive it from the screen spec:
   - columns and form fields → attributes; filters → indexes; dropdowns → static entities
     or foreign keys; each button → one `_BL` action; roles → screen roles and role
     checks in each `_BL` action
   - every entity that a screen writes to gets `<Entity>_Save` (and `<Entity>_Delete` if
     the screen deletes) in `_BL` — see "Standard save and delete" in `/logic`
   - a block only if the same UI is used in more than one place
   - a service action only if another domain or app needs it
   - an `_IS` endpoint only if the story needs data from an external system
   - an `_API` method only if an external system must call us
   - for small lookup entities (3–4 fields), prefer editing in a popup on the list screen
     over a separate detail screen
3. **Assumptions** you made, numbered, so the developer can correct them.

## Step 4: the commands, in order
Write each command as a separate, numbered, copy-paste block, complete enough to run
without this conversation. Use the argument format of each command and the action
`create` or `edit` from step 1.

Order (dependencies first):
1. Static entities
2. Entities — parents before children
3. CRUD (`/crud create`, or `/crud edit` for existing entities)
4. `_IS` endpoints (`/api-consume`) the logic needs
5. `_BL` actions — Save/Delete first, then one per button
6. Service actions — only if needed
7. Blocks — only if reused
8. Screens — list first, then detail
9. `_API` methods — only if needed

Under each command add one line: **Check after:** what the developer verifies before
running the next one (e.g. "entity has 9 attributes and indexes on InspectorId, StatusId").

End with:
- **Test the story:** the acceptance criteria as manual test steps.
- **Out of scope:** anything in the story you did not cover, and why.

## Rules
- Every command must follow `architecture.md`: screens read with aggregates and write through
  their own `_BL`; `_SL` only for other domains; no references `_API` or upward.
- Names follow `naming.md`. Each entity, attribute and action in the commands has a short
  description so the command can set it.
- Do not split one element across two commands, and do not merge two elements into one command.
- If the story is too large for about 15 commands, split it into smaller stories and say
  how, instead of producing one long list.
- When the developer reports that a command ended differently from the plan (a name taken,
  a field changed), update the remaining commands and show only those again.
