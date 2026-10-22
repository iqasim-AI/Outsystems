---
description: Story review — review a story's implementation against its ticket and the team rules (read-only, changes nothing)
argument-hint: <ticket link> [technical comment]
---

# Story review

Request: $ARGUMENTS

Review what was built for this story. Follow CLAUDE.md and .claude/rules/, especially
`review.md`, `architecture.md` and `coding.md`.

**This command changes nothing.** Use the OutSystems MCP only to read. Do not create, change
or publish anything, and do not comment on the ticket.

## Step 1: read the ticket
Open the ticket link and read the description, field table, business rules, pre/post-conditions,
acceptance criteria and the comment thread. If it asks for a sign-in, ask me to sign in; never
enter credentials. Take the technical comment from the request, or from the ticket's comments.

## Step 2: read what was built
Use the OutSystems MCP to inspect every module and element the comment names, and the elements
they call:
- `_CS`: entities, attributes, indexes, static entities, CRUD actions
- `_BL`: each action's flow, validations, role checks, exception handlers
- `_SL`, `_IS`: service actions and integration wrappers
- `_UI`, `_CW`: screens and blocks — data actions, buttons, uploaders, events

If a module isn't open or you can't read it, list it and say it wasn't reviewed.

## Step 3: check
Trace every ticket requirement to the code, then check every rule in `review.md` and the rules
it builds on. Each finding names the module and element and quotes the evidence.

## Step 4: report
In the order set in `review.md` → "Report":
Scope → ❌ Ticket gaps → 🔴 Must fix → 🟠 Should fix → 🟢 Confirm → ✅ Good.

End with the fixes as numbered, copy-paste team commands in dependency order (as in `/story`):
`/entity`, `/crud`, `/logic` + `/test`, `/service-action`, `/block`, `/screen`. Use `edit` for
what exists. Under each command add one **Check after:** line.
