---
description: Expose API — create or edit one REST API method for other systems (in the _API module)
argument-hint: create|edit <MethodName> in <Domain>_API: <what it does, inputs, outputs, or the change>
---

# Expose API: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — no business rules, no CRUD, no UI.
Follow CLAUDE.md and .claude/rules/. Work in Development only.

The REST API lives in `[Domain]_API`. It is an entry point for **external** systems only;
no OutSystems module references `_API`.

## Design rules (create and edit)
- **Thin wrapper**: contract, authentication, input validation, DTO mapping. It calls the
  own domain's `_BL` server action (or another domain's `_SL`) that holds the logic. If that
  action doesn't exist, stop and tell me which command to run first (`/logic create`).
- Reuse the same REST API (e.g. `VehicleAPI`) and add a method; don't create a new API per method.
- **Contract**:
  - Method name in PascalCase (e.g. `CheckVehiclesEligibility`).
  - HTTP method: GET for simple reads with few parameters; POST when input is a list or a body.
  - URL path in kebab-case, versioned: `/v1/vehicles/check-eligibility`.
  - Request and response use Structures named `<Method>Request` / `<Method>Response`,
    never Entity records. JSON field names in camelCase (set Name in JSON).
  - Mark mandatory fields; set a max list size if input is a list (reject above it).
  - Response always includes: `success`, `errorCode`, `errorMessage`, `requestId`, data.
- **Security**:
  - Authentication: [Basic / Custom (API key or token in header)] — validate in OnAuthentication.
  - Credentials and keys come from Site Properties / Settings, never hard-coded.
  - Validate every input on the server (format, length, required) before calling logic.
  - Never return stack traces or internal details to the caller.
- **Errors and HTTP status**:
  - 200 OK with `success = false` + `errorCode` for business results (e.g. not eligible).
  - 400 for invalid input, 401 for auth failure, 500 for unexpected errors.
  - Clear error codes, e.g. `INVALID_INPUT`, `LIMIT_EXCEEDED`, `UNAUTHORIZED`.
- **Logging**: log each request with requestId, caller, duration and result (OnResponse or a
  log action). Never log personal data (national IDs, tokens).

## create
1. Use the OutSystems MCP to check existing REST APIs in the module. If the same method
   exists, stop (I may want `edit`).
2. Show the plan: HTTP method, URL, request/response structures with a sample JSON, auth,
   error codes, the `_BL`/`_SL` action it calls. Wait for my approval.
3. After approval: create, publish `_API` to Development, and report the endpoint URL,
   a sample request (curl) and a sample response.

## edit
Follow `.claude/rules/editing.md`, plus these API rules:

- **Callers are external and invisible.** Assume every published method is in use. List
  the known consumers from the "Exposed APIs" section of CLAUDE.md.
- **Allowed in place (non-breaking)**: add an optional request field, add a response
  field, relax validation, fix a bug without changing the contract, change internals.
- **Breaking** (needs a new version): remove or rename a field, change a type or format,
  make a field mandatory, tighten validation, change the URL, HTTP verb or authentication,
  change the meaning of an error code or a result.
- **New version**: add a new method `<Method>V2` on `/v2/...` with its own structures
  (`<Method>V2Request` / `<Method>V2Response`). Keep v1 working, mark it
  `Deprecated: use /v2/...` in its description, and list the consumers to migrate.
- **Changes to the rules** behind the API belong in `_BL` (`/logic edit`). Edit the API
  only for its contract, validation, auth or mapping.
- The report includes the updated sample request (curl) and sample response, and marks
  every changed field.
