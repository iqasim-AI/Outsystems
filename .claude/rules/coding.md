# Coding rules

Our apps are OutSystems 11 **Reactive Web**. Do not use Traditional Web patterns
(Preparation, screen-level server logic).

## Data access
- Use Aggregates first. Use Advanced SQL only when an aggregate can't do it, and explain why.
- Set Max Records on every aggregate. Fetch only what the screen or action uses.
- Paginate every list screen (page size: 20).
- Never run an aggregate, SQL or service action inside a loop. Fetch once with a join
  or filter, then loop over the result.
- Advanced SQL: always use parameters and {Entity}.[Attribute] syntax. Never set
  Expand Inline = Yes on input from users or external systems; if unavoidable, use EncodeSql.

## Client and server
- One server call per user event. Combine the work into one server action instead of
  calling several in a row from a client action.
- Every server action called from a screen is a public endpoint: check the role inside
  it, not only on the screen.
- Never keep sensitive data in client variables or local storage.

## Validation
- Validate on the server. Client checks are for user experience only and are never trusted.
- Use the built-in Valid / ValidationMessage on form inputs.

## Exceptions
- Business errors: raise a User Exception with a clear, user-friendly message.
- Technical errors: log the details, show a generic message. Never show stack traces
  or SQL errors to users.
- Every UI flow has a global exception handler.
- Never catch an exception and do nothing.
- In server actions, keep Abort Transaction = Yes on exception handlers unless you
  deliberately want the earlier changes kept (and say so in the description).

## Logging
- Log with the built-in `LogMessage` action (System). Set `ModuleName` to the module
  and write a short message that says what failed and with which record Id.
- Never log personal data: national IDs, phone numbers, tokens, passwords.

## Values
- Compare against static entity identifiers (Entities.RequestStatus.Approved), never
  labels or hard-coded IDs.
- No magic numbers or strings: use static entities or Site Properties.

## Timers
- Process in batches, commit after each batch, and re-wake the timer before the
  timeout instead of processing everything in one run.

## Reuse and change size
- Search existing actions with the OutSystems MCP before creating new ones.
- Give every public element (action, entity, attribute, structure) a description.
- Prefer small, incremental changes over one big change.
