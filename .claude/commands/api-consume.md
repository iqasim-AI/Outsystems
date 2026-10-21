---
description: Consume API — create or edit one consumed external endpoint in an _IS module, following an existing reference module (O11)
argument-hint: create|edit, then the template from prompts/examples/08-consume-endpoint-check-vehicles-eligibility.md (create) or the endpoint and the change (edit)
---

# Consume API: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Follow CLAUDE.md and .claude/rules/. Work in Development only.

Consumed external APIs live ONLY in `[System]_IS` (Foundation): no business logic and no
references to Core modules. `_BL` calls the `_IS` wrapper action, never the external system
directly (see `architecture.md`).

## create

The request must give:
- **Target module**: where ALL new work goes (e.g. `Integration_ELM_IS`)
- **Reference module**: copy from only, never modify (e.g. `Eservices_CRM_IS`)
  - Reference consumed REST API, including its `OnBeforeRequest` / `OnAfterResponse`
  - Reference service action to use as a template
  - Reference log entity to use as a template
- **Endpoint**: method name, HTTP verb, path
- **Request** sample JSON and **response** samples: success, business failure, error (problem+json)
- **Structures** to create (optional; derive them from the samples if not given)
- **Business error codes** with descriptions (optional)
- **Service action**: name, folder, extra inputs/outputs (optional)
- **Log entity** name (optional)

If any required item is missing, ask for it before starting. If the endpoint is already
consumed in the target module, stop (I may want `edit`).

Follow the conventions you find in the reference module exactly: naming, folders,
structures, exception handling and logging. Adapt names to fit the target module.

### Step 1: analyse first (no changes yet)
1. In the reference module, open the reference consumed REST API and document:
   - its base URL and the site property it uses
   - what `OnBeforeRequest` does (auth token, headers, correlation ID, etc.)
   - what `OnAfterResponse` does (status-code handling, error mapping, logging)
   - every dependency they use (site properties, server actions, structures, module references)
   - the HTTP verb and path style of its existing methods
2. Open the reference service action and document:
   - input/output parameters
   - how it calls the API
   - exception handling flow
   - how and when it writes to the log entity, and how the log survives a rollback
   - what output it returns
3. Open the reference log entity and list its attributes, indexes and how they are populated.
4. Check whether the target module already has the same consumed API, a similar log entity,
   static entity, structures or site properties, to avoid duplicates.
5. Report back: a summary, the list of dependencies to recreate in the target module, and
   your implementation plan. **Wait for my confirmation before modifying anything.**

### Step 2: consumed REST API in the target module
- If the target module already consumes the same API, add the method to it.
  Otherwise recreate the consumed API with the same base URL configuration (site property).
- Copy `OnBeforeRequest` and `OnAfterResponse` logic, plus the helper actions and structures
  they depend on.
- Copy ONLY the requested method. Do not copy other methods unless asked.
- Do NOT add a reference from the target module to the reference module. Copy what's needed.
- Confirm the HTTP verb against the existing methods of the reference API.
- Create the request/response structures and a problem-details structure
  (Type, Title, Status, Detail, Instance) from the samples. Set JSON names to match exactly.

### Step 3: business error codes (if provided)
- Create a static entity `<Method>ErrorCode` (or follow the module's naming) with
  Code, DescriptionEN, DescriptionAR, one record per code.
- Unknown codes must not break the flow: log them and return the raw code with an empty description.

### Step 4: HTTP error handling
Follow the copied `OnAfterResponse` / template service action pattern and map:
- **400** bad request: malformed request or invalid fields
- **401** unauthorized: missing or expired token
- **403** forbidden: no permission for this resource
- **404** not found: functional "not found" result, not a technical crash
- **500** provider platform error
- Parse the problem+json body when present and use its `detail` in the error message.
- Catch and log timeouts and connection failures.

### Step 5: service action in the target module
Mirror the reference service action, in a folder that follows the module's conventions:
- **Input**: the endpoint's request fields, plus the same context inputs the template takes.
- **Output**: IsSuccess, the response fields, ErrorCodes (code + description) if any,
  HttpStatusCode, ErrorMessage.
- **Validation**: check mandatory/format rules (e.g. ID > 0) and return an error
  WITHOUT calling the API if invalid.
- Never let raw exceptions reach the consumer. Use the template's exception-handler pattern.

### Step 6: log entity in the target module
Create a log entity modelled on the reference log entity. Copy its attributes and include:
- the main request key(s) (e.g. SequenceNumber)
- RequestPayload, ResponsePayload, HttpStatusCode
- the main result fields (e.g. IsEligible), ErrorCodes (comma-separated), ErrorMessage
- DurationMs, CreatedOn, CreatedBy
- any correlation/request ID the reference log uses

Requirements:
- Log every call: success, business failure, HTTP error and exception.
- The log must survive an exception rollback (use the same technique as the template).
- Index the main request key and CreatedOn.
- Mask tokens and sensitive headers; never log the Authorization header.

### Step 7: verify
1. Run TrueChange on the target module and fix every error and warning you introduced.
2. Test with each sample response given above (success, business failure, error).
3. Final summary:
   - every element created in the target module, with its folder
   - assumptions you made
   - manual setup needed (site properties, roles, credentials)

### Rules (create)
- The reference module is **read-only**: do not modify, publish or add references to it.
- Do not rename, delete or refactor any existing element in the target module.
  To change an existing endpoint, use `/api-consume edit`.
- Development environment only.
- If anything in the existing patterns is ambiguous, ask instead of guessing.

## edit

Follow `.claude/rules/editing.md`, plus these integration rules.

The request must give: the `_IS` module, the consumed method (or wrapper service action),
and what changed. For a contract change, also the new request/response samples from the
provider. If any of these is missing, ask for it before starting.

- **Base URL, credentials or keys changed**: no code change. Tell me which Site Property /
  Setting to update and in which environments; values outside Development are set by the
  team in Service Center (`environments.md`). Never put credentials in the repo or the prompt.
- **Provider changed the contract** (new, renamed or removed fields):
  - Update the method and its request/response structures from the new samples; set the
    JSON names to match exactly.
  - Keep the wrapper service action's inputs and outputs **stable** for its `_BL` callers.
    Map the new fields inside the wrapper. If the wrapper's contract must change, follow the
    service action rules in `/service-action` (optional additions only, otherwise `_V2`).
  - List every `_BL` action that calls the wrapper, and whether each needs `/logic edit`.
- **New business error codes**: add records to the error-code static entity. Never delete
  or rename existing codes; unknown codes must still be logged and returned, not break the flow.
- **Log entity**: add attributes for new fields; never remove existing ones (old log rows
  keep them). Tokens and sensitive headers stay masked.
- **`OnBeforeRequest` / `OnAfterResponse`**: they apply to **every** method of the consumed
  API. Change them only if the request asks, and list every method affected.
- **HTTP error mapping**: keep the same mapping as the create steps (400, 401, 403, 404,
  500, timeouts) unless the provider changed its behaviour.
- **Verify**: run TrueChange on the `_IS` module and its callers, then test with every new
  sample (success, business failure, error) and with one old sample to confirm nothing
  else broke.
- The reference module stays **read-only**. Change only the elements the request names.
