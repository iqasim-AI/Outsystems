---
description: Step 8 — Consume one external REST API method (in the _IS module)
argument-hint: <MethodName> in <System>_IS: <endpoint, method, request, response>
---

Consume ONE external REST API method. Do only this step — no business rules, no UI.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md. Work in Development only.
2. Integrations live in `[System]_IS` (e.g. `Traffic_IS`). Nothing outside `_IS` calls
   the external system directly; `_BL` calls the `_IS` wrapper action.
3. Use the OutSystems MCP to check if the REST API or a similar method is already consumed.
   Reuse it and add the method instead of consuming the API again.
4. Setup:
   - Base URL in a Site Property / Setting per environment — never hard-coded.
   - Auth (API key / OAuth token / Basic) from Settings; add headers in OnBeforeRequest.
   - Set a timeout (default [30] seconds).
   - If I give a sample JSON or Swagger, generate the structures from it.
5. Wrapper action:
   - Create a public server action `<System>_<Method>` (e.g. `Traffic_GetVehicleStatus`)
     that calls the REST method and returns clean output Structures.
   - Map external field names to our naming; don't leak external structures to `_BL`.
   - Handle errors: timeout, 4xx, 5xx, empty or invalid response. Return
     Success + ErrorCode + ErrorMessage instead of raising raw exceptions.
   - Retry only for safe reads (GET), at most [2] times, on timeout or 5xx.
6. Logging:
   - Log request/response metadata (URL, status, duration). Mask secrets and personal IDs.
7. Show the plan first: endpoint, method, auth, structures, wrapper action, error mapping.
   Wait for my approval.
8. After approval: create, publish `_IS` to Development, and report how `_BL` should call it.
