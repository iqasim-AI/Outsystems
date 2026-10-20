# Architecture rules

Each domain is split into these modules. Calls go top to bottom, never up.

| Layer | Module | Contains | May call |
|---|---|---|---|
| API | `[Domain]_API` | Exposed REST APIs (thin: contract, auth, validation) | `_SL` service actions [confirm: also `_BL`?] |
| UI | `[Domain]_UI` | Screens, blocks, client actions | `_SL` service actions [confirm: also `_BL`?] |
| Service | `[Domain]_SL` | Service actions (public API of the domain) | `_SL` of other domains, `_BL`, `_CS` server actions |
| Logic | `[Domain]_BL` | Business-logic server actions | `_CS` CRUD actions, other `_BL`, server actions of other modules, `_SL` service actions of OTHER domains |
| Core | `[Domain]_CS` | Entities, static entities, CRUD server actions | Foundation only |
| Foundation | `_IS`, `_Th`, libs | Integrations, theme, utilities | none |

## Where things live
- Entities and CRUD live ONLY in `_CS`. No other module writes to entities directly.
- Business rules live ONLY in `_BL`. They write data by calling `_CS` CRUD actions.
- Service actions live ONLY in `_SL`. They are thin: call `_BL` / `_CS` / other `_SL`, no business rules.
- Exposed REST APIs live ONLY in `_API`.
- Consumed external APIs live ONLY in `[System]_IS`. `_BL` calls the `_IS` wrapper action, never the external system directly.
- Never create circular references between modules.
- Shared libraries: [list e.g. Common_Lib, Theme_Lib]

## Calls and transactions
- A `_BL` action may call server actions from other modules and service actions from OTHER domains' `_SL`.
  It must never call its own domain's `_SL` (that `_SL` already references this `_BL`, so it would be circular).
- When `_BL` calls a service action, that call commits on its own. If the `_BL` action fails afterwards,
  the service action's changes are NOT rolled back. Call service actions last, or add compensation (undo) logic.
- A service action may call another service action or a server action from a different module.
  Each service action runs in its own transaction: if one call commits and a later one fails,
  the first is NOT rolled back. For multi-step writes that must be all-or-nothing, put them
  in one `_BL` server action instead, or add compensation logic.
