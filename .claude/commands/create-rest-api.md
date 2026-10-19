---
description: Step 7 — Expose one REST API method for other systems (in the _API module)
argument-hint: <MethodName> in <Domain>_API: <what it does, inputs, outputs>
---

Expose ONE REST API method. Do only this step — no business rules, no CRUD, no UI.

Request: $ARGUMENTS

Rules:
1. Follow CLAUDE.md. Work in Development only.
2. The REST API lives in `[Domain]_API`. It is a thin wrapper: it calls a `_SL` service
   action (or `_BL` server action) that holds the logic. If that action doesn't exist,
   stop and tell me which command to run first (`/create-logic`, `/create-service-action`).
3. Use the OutSystems MCP to check existing REST APIs in the module. Reuse the same
   REST API (e.g. `VehicleAPI`) and add a method; don't create a new API per method.
4. API contract:
   - Method name in PascalCase (e.g. `CheckVehiclesEligibility`).
   - HTTP method: GET for simple reads with few parameters; POST when input is a list or a body.
   - URL path in kebab-case, versioned: `/v1/vehicles/check-eligibility`.
   - Request and response use Structures named `<Method>Request` / `<Method>Response`,
     never Entity records. Field names in camelCase in JSON (set Name in JSON).
   - Mark mandatory fields; set max list size if input is a list (reject above it).
   - Response always includes: `success`, `errorCode`, `errorMessage`, `requestId`, data.
5. Security:
   - Authentication: [Basic / Custom (API key or token in header)] — validate in OnAuthentication.
   - Credentials and keys come from Site Properties / Settings, never hard-coded.
   - Validate every input on the server (format, length, required) before calling logic.
   - Never return stack traces or internal details to the caller.
6. Errors and HTTP status:
   - 200 OK with `success = false` + `errorCode` for business results (e.g. not eligible).
   - 400 for invalid input, 401 for auth failure, 500 for unexpected errors.
   - Use clear error codes, e.g. `INVALID_INPUT`, `LIMIT_EXCEEDED`, `UNAUTHORIZED`.
7. Logging and tracing:
   - Log each request with requestId, caller, duration and result (OnResponse or a log action).
   - Mask sensitive values (national IDs, tokens) in logs.
8. Show the plan first: HTTP method, URL, request/response structures with a sample JSON,
   auth, error codes, the `_SL`/`_BL` action it calls. Wait for my approval.
9. After approval: create, publish `_API` to Development, and report the endpoint URL,
   a sample request (curl) and a sample response.
