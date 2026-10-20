# Architecture rules

These rules follow the OutSystems Architecture Canvas (End-User, Core, Foundation).
We do not use an Orchestration layer.
They apply to every module you create or change. If a request would break one of
them, stop and say which rule it breaks and propose the compliant alternative
(see "Fixing violations") instead of creating the reference.

## The three Canvas rules (always true)

1. **No upward references.** A module never references a module in a higher layer.
2. **No side references between End-User modules** (`_UI`). They never provide
   reusable logic, blocks or functions to other modules.
3. **No cycles** among Core or Foundation modules, direct or indirect
   (A → B → C → A counts).

Our Core tiering (`_SL` > `_BL` > `_CS`) is a **team convention on top of the Canvas**.
OutSystems treats all three as Core; the tiering exists so that cycles cannot form
inside a domain.

## Modules per domain

| Canvas layer | Module | Contains | May reference |
|---|---|---|---|
| End-User | `[Domain]_UI` | Screens, screen-specific blocks, client actions | Own `_BL`; own `_CS` entities (read-only); other domains' `_SL`; other domains' `_CS` entities (read-only); `_CW`; Foundation. Screen links to other `_UI` only. |
| Core | `[Domain]_API` | Exposed REST APIs: contract, auth, input validation, DTO mapping. No business rules. | Own `_BL`; other domains' `_SL`; Foundation. **No module references `_API`.** |
| Core | `[Domain]_SL` | Service actions = the domain's public contract for other domains/apps. Thin, no business rules. | Own `_BL`; own `_CS`; other domains' `_SL` (downward in domain order only); Foundation |
| Core | `[Domain]_BL` | Business-logic server actions | Own `_CS`; other domains' `_SL` (downward in domain order only); Foundation. **Never** its own domain's `_SL`. |
| Core | `[Domain]_CW` | Reusable business-aware blocks (e.g. a beneficiary summary card) | Own `_CS` (read-only), own `_BL`, Foundation |
| Core | `[Domain]_CS` | Entities, static entities, CRUD server actions | Other `_CS` (no cycles), Foundation |
| Foundation | `[System]_IS` | Wrappers for consumed external APIs; normalized structures | Other Foundation only |
| Foundation | `_Th`, `_Lib`, pattern libs | Theme, business-agnostic utilities, generic UI patterns | Other Foundation only |

Anything not listed in "May reference" is forbidden.

## Where things live

- **Entities and CRUD live ONLY in `_CS`.** Entities are `Public = Yes` and
  `Expose Read Only = Yes`. No other module writes to an entity directly.
- **Reads:** `_UI` modules read entities directly with aggregates (own domain or
  other domains, read-only). Do not route simple screen reads through service actions.
- **Writes:** every write goes through `_BL`, which calls `_CS` CRUD actions.
  `_UI` and `_API` call `_BL`; they never call `_CS` CRUD actions directly.
  Writes to another domain's data go through that domain's `_SL`.
- **Business rules live ONLY in `_BL`.**
- **Service actions live ONLY in `_SL`.** They are thin: call own `_BL` / `_CS` or
  other domains' `_SL`. No business rules.
- **Exposed REST APIs live ONLY in `_API`.** `_API` is an entry point for external
  consumers only. Internal modules use `_SL` or `_BL`, never our own REST APIs.
- **Consumed external APIs live ONLY in `[System]_IS`.** `_BL` calls the `_IS` wrapper
  action, never the external system directly. `_IS` has no business logic and no Core
  references. If external data must be stored, synced or validated against business
  rules, that belongs in `_CS` + `_BL`, not in `_IS`.
- **Shared blocks:** business-aware → `[Domain]_CW`; business-agnostic → a Foundation
  pattern library. Never reuse a block or function from another `_UI` module.
- **Shared libraries:** [fill in, e.g. `Common_Lib`, `Theme_Th`]

## Domain dependency order

Cross-domain calls (`_BL` → other `_SL`, `_SL` → other `_SL`) are allowed **only
downward** in this order. A domain may call domains listed below it, never above.

[fill in, top to bottom, e.g.:]
1. [Domain A]
2. [Domain B]
3. [Domain C]

If a new requirement needs a call upward in this order, do not add it. Stop and raise
it: either the logic belongs in a composition module above both domains, or the order
needs to change (Tech Lead decision).

## Server action or service action?

- **Same domain:** server action (`_BL`), strong reference, shared transaction.
- **Another domain / another app with its own release cycle:** service action (`_SL`).
- Service actions reduce republishing when the provider changes, but the logical
  dependency still exists. A cycle through service actions is still a violation.
- Client actions cannot call service actions directly. Wrap the call in a server action
  or a data action.
- Service actions are remote calls with overhead. Do not call them in loops or for
  fine-grained reads; prefer one coarse call or an aggregate.

## Calls and transactions

- A `_BL` action never calls its own domain's `_SL` (that `_SL` already references
  this `_BL`, so it would be circular).
- **Each service action runs in its own transaction and commits on its own.**
  - When `_BL` calls a service action and then fails, the service action's changes are
    NOT rolled back. Call service actions last, or add compensation (undo) logic.
  - When a service action calls several others and a later one fails, the earlier ones
    are NOT rolled back.
- For multi-step writes that must be all-or-nothing, keep them in **one `_BL` server
  action** in a single transaction, or add explicit compensation logic.
- Exceptions raised in a service action reach the caller as errors; handle them in the
  caller and do not assume earlier steps were undone.

## Naming

- Modules: `[Domain]_UI`, `[Domain]_API`, `[Domain]_SL`, `[Domain]_BL`, `[Domain]_CW`,
  `[Domain]_CS`, `[System]_IS`, `[Name]_Th`, `[Name]_Lib`.
- One concept per module. If a module grows too large, split by sub-concept, not by layer.

## Before adding any reference, check

1. Is the target in the same or a lower layer? (rule 1)
2. Is the target an End-User module? Only screen links are allowed. (rule 2)
3. Is the target an `_API` module? Never reference it.
4. Could this reference close a loop, directly or through other modules? (rule 3)
5. For cross-domain calls: is the target domain below this one in the domain order?
6. Does the target appear in this module's "May reference" column?

If any answer fails, do not add the reference.

## Fixing violations

- **Upward reference:** move the consumed element to a lower layer: to `_CS`/`_BL`/`_CW`
  if business-related, to a Foundation library if business-agnostic.
- **Side reference between `_UI` modules:** move the shared element to `_CW`
  (business-aware) or a Foundation library (agnostic).
- **Cycle between A and B:**
  - If one direction is wrong, move the elements B consumes from A into B (if they are
    the same concept) or into a new module (if they are a separate reusable concept).
  - If A and B are tightly coupled, merge them.
  - If the merge would be too large, keep A and B as base concepts and put the logic
    that combines them in a module above both (`_BL` in the same app, `_SL` across apps).

## Validation

Run AI Mentor Studio on the environment to detect upward references, side references
and cycles. New violations must be fixed before the change is promoted.
