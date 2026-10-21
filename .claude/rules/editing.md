# Editing existing elements

Every `edit` action (`/entity edit`, `/crud edit`, `/logic edit`, `/service-action edit`,
`/block edit`, `/screen edit`, `/api-expose edit`, `/api-consume edit`) follows these steps.
Each command adds the rules specific to its element.

## 1. Find and read it first
- Use the OutSystems MCP to open the element in the named module.
  If it doesn't exist, stop and say so (the developer may want `create`).
  If more than one element matches, list them and ask which one.
- Read its current definition before changing anything: inputs, outputs, attributes,
  events, flow, roles, references.

## 2. Find who uses it (impact analysis)
- List every consumer the MCP can see: modules that reference it, and the actions,
  screens, blocks, timers and APIs that use it.
- Say clearly what you **cannot** see: consumers in other apps or teams of a service
  action, and external callers of an exposed REST API. Treat those as existing.

## 3. Classify the change

| Non-breaking (safe) | Breaking (needs explicit approval) |
|---|---|
| Add an **optional** input with a default value | Rename or remove an element, input, output, attribute, event or JSON field |
| Add an output or a response field | Change a data type or format |
| Add an optional attribute, or a mandatory one with a default value | Make an optional input or attribute mandatory |
| Change internal logic with the same contract **and** the same meaning | Change what an output means, or tighten validation callers rely on |
| Add a non-unique index | Change a URL, HTTP verb, authentication or screen roles |
| Add a static entity record | Delete or rename a static entity record used in code |

## 4. Prefer the non-breaking way
- Add instead of change: a new optional input, a new attribute, a new output.
- For service actions and exposed REST APIs, a breaking change becomes a **new version**
  (`<Name>_V2`, `/v2/...`). Keep the old one working.
- Mark the old element `Deprecated: use <new name>` in its description instead of
  deleting it.
- Service actions and links between modules are weak references: a breaking change
  in them fails **at runtime** in consumers that were not republished, not in Service
  Studio. This is why they are versioned instead of changed.

## 5. Show the plan and wait for approval
The plan always contains:
- A **Before | After** table of what changes.
- The consumers found in step 2, and for each one whether it must be updated.
- Whether the change is breaking, and why.
- Any new references, checked against the checklist in `architecture.md`.
- Data risks (existing records, truncation, mandatory values) and how they are handled.
- The publish order (step 7).

Wait for approval. For a breaking change, the approval must cover every consumer
that has to be updated.

## 6. Make the smallest change
- Change only what the request names. Do not rename, reorder, restyle or refactor
  anything else, even if it looks wrong. Mention it in the report instead.
- Keep descriptions current: update the description of every element you changed.
- The result must still follow `architecture.md` and `coding.md`.
- Never delete entities, attributes, static entity records or data without explicit
  approval (`never-do.md`). Never change shared Foundation modules without telling the team.

## 7. Publish in dependency order (Development only)
1. Publish the changed module.
2. In each consumer: refresh the reference (Manage Dependencies), fix what broke,
   publish. Go from the lowest layer up: `_CS` → `_BL` → `_SL` → `_UI` / `_API`.
3. Run TrueChange on the changed module and every consumer you touched. No new errors
   or warnings.

## 8. Report
- What changed: before → after.
- Modules published, in order.
- Consumers updated, and consumers that could not be seen and must be told
  (other apps, external API callers).
- Anything you noticed but did not change.
