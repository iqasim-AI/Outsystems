---
description: Consume one external endpoint in an _IS module by copying the patterns of an existing reference module (O11)
argument-hint: fill in the template from prompts/examples/08-consume-endpoint-check-vehicles-eligibility.md
---

# Task: consume one external endpoint, following an existing reference module

Details for this endpoint (filled in by the developer):

$ARGUMENTS

The details above must give:
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

If any required item is missing, ask for it before starting.

Follow the conventions you find in the reference module exactly: naming, folders,
structures, exception handling and logging. Adapt names to fit the target module.

## Step 1: analyse first (no changes yet)
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

## Step 2: consumed REST API in the target module
- If the target module already consumes the same API, add the method to it.
  Otherwise recreate the consumed API with the same base URL configuration (site property).
- Copy `OnBeforeRequest` and `OnAfterResponse` logic, plus the helper actions and structures
  they depend on.
- Copy ONLY the requested method. Do not copy other methods unless asked.
- Do NOT add a reference from the target module to the reference module. Copy what's needed.
- Confirm the HTTP verb against the existing methods of the reference API.
- Create the request/response structures and a problem-details structure
  (Type, Title, Status, Detail, Instance) from the samples. Set JSON names to match exactly.

## Step 3: business error codes (if provided)
- Create a static entity `<Method>ErrorCode` (or follow the module's naming) with
  Code, DescriptionEN, DescriptionAR, one record per code.
- Unknown codes must not break the flow: log them and return the raw code with an empty description.

## Step 4: HTTP error handling
Follow the copied `OnAfterResponse` / template service action pattern and map:
- **400** bad request: malformed request or invalid fields
- **401** unauthorized: missing or expired token
- **403** forbidden: no permission for this resource
- **404** not found: functional "not found" result, not a technical crash
- **500** provider platform error
- Parse the problem+json body when present and use its `detail` in the error message.
- Catch and log timeouts and connection failures.

## Step 5: service action in the target module
Mirror the reference service action, in a folder that follows the module's conventions:
- **Input**: the endpoint's request fields, plus the same context inputs the template takes.
- **Output**: IsSuccess, the response fields, ErrorCodes (code + description) if any,
  HttpStatusCode, ErrorMessage.
- **Validation**: check mandatory/format rules (e.g. ID > 0) and return an error
  WITHOUT calling the API if invalid.
- Never let raw exceptions reach the consumer. Use the template's exception-handler pattern.

## Step 6: log entity in the target module
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

## Step 7: verify
1. Run TrueChange on the target module and fix every error and warning you introduced.
2. Test with each sample response given above (success, business failure, error).
3. Final summary:
   - every element created in the target module, with its folder
   - assumptions you made
   - manual setup needed (site properties, roles, credentials)

## Rules
- The reference module is **read-only**: do not modify, publish or add references to it.
- Do not rename, delete or refactor any existing element in the target module.
- Development environment only.
- If anything in the existing patterns is ambiguous, ask instead of guessing.
