# Review rules

Use these rules when reviewing a story's implementation (`/story-review`). They add review
checks on top of `architecture.md`, `coding.md`, `security-roles.md`, `naming.md` and
`testing.md`. A finding against any of those files counts the same as one against this file.

A review reports findings. It changes nothing: no module edits, no ticket comments, no publish.

## Sources
- Read the ticket itself: description, field table, business rules, pre/post-conditions,
  acceptance criteria and the comment thread. If the tracker asks for a sign-in, ask the
  developer to sign in. Never enter credentials.
- Inspect the real modules with the OutSystems MCP. Never review the technical comment alone:
  it says what the developer meant to build, not what was built.
- Say which modules you inspected and which you couldn't (not open, no access).
- Quote element names and values from the code as evidence for every finding.

## Ticket first
- Every business rule, pre/post-condition and acceptance criterion maps to code, or is a finding.
  Ticket gaps outrank best-practice findings.
- Statuses follow the ticket's lifecycle. A record created in a final status when the ticket says
  it starts as a draft is a must-fix.
- "Save as draft" in the ticket means the server accepts an incomplete record.
- Audit / history entries the ticket asks for are written, with user, date/time and key data.
- Side effects the ticket asks for happen (recalculations, totals, refreshed lists).
- Limits match exactly: file count, file types, size per file, text lengths, ranges.
- Decisions in the comment thread count (an analyst confirming a field is mandatory).
- Ticket text about another flow (edit, external portal) is flagged so its scope is confirmed.
- Every business rule in the ticket has a `/test` scenario (`testing.md`).

## Layers
- Every reference passes the checklist in `architecture.md`. An upward reference, a side
  reference between `_UI` modules or a cycle is a must-fix.
- Business rules are only in `_BL`. Rules found in `_UI`, `_CW`, `_SL` or `_IS` are findings.
- Screens read with aggregates and write through their own `_BL`. A screen that calls its own
  domain's `_SL` is a finding: `_SL` is only for other domains and apps.

## Data model (_CS)
- Every child entity has a mandatory FK to its owner. An owner reachable only through an optional
  attribute on another table is a finding.
- Every business uniqueness rule has a unique index. A check-then-insert alone lets duplicates in.
- Mandatory flags match the business rules.
- Business entities have audit attributes: CreatedBy, CreatedOn, UpdatedBy, UpdatedOn.
- Indexes exist on the attributes used in filters and joins.
- New static entity records get the next free Id, with Label, Order and Is_Active set.
- Names follow `naming.md` and are spelled the same way everywhere (entity, structure, folder, FK).
  Fix spelling while the code is new; renames get expensive once other modules consume it.

## Logic (_BL)
- Check the role (the ticket's actors) inside the action, and check that the user may act on
  every Id received. Ids from the client are never trusted.
- Check that each Id belongs to its parent record.
- Check the ticket's preconditions on the server. Hiding a button is not enough.
- Trim and normalize inputs, then validate all of them: required, format, range, dates.
- Attachments: the DMS Id exists, was uploaded by the current user, isn't linked yet, and has an
  allowed type and size.
- Duplicate checks use the full business key and have an index behind them.
- Write the audit entry in the same transaction as the change.
- Never return `ExceptionMessage` to the UI. Log it, return a generic, user-friendly message.
- No dead branches: don't re-check what earlier validation already guarantees.
- Actions only `_BL` itself uses are not Public.

## External services
- If an integration already exists for the data (identity, address, banking, document,
  notification services), use it. Don't ask the user to type data a service can return, and don't
  build a second `_IS` module for the same service.
- `_BL` calls the `[System]_IS` wrapper, never the external system directly and never from the UI.
- Re-verify on the server before saving and overwrite client values with the verified ones.
  A client "verified" flag is never trusted.
- Call external services before the first write, so no locks are held while waiting.
- Handle the service being down or slow: a timeout, a clear message, no partial save.

## Database hits
- One aggregate with joins instead of several aggregates for the same screen or action.
- Never query inside a loop. Fetch once with a join or filter, then loop over the result.
- Don't re-read a record you just created or updated: use the Id and data you already have.
- Read static entity values with `Entities.X.Y`; don't query a static entity for a single value.
- Load what a screen needs in as few data actions as possible, not one call per field or dropdown.
- Fetch only the attributes and rows the screen or action uses; set Max Records.
- Let the unique index catch duplicates where possible, instead of an extra lookup per save.
- Prefer one bulk operation (a list write or Advanced SQL) over many single-row writes.

## Files
- Files are uploaded only through DMS. No binary data is sent to `_BL` or `_SL`; the backend
  receives the DMS Id and file name only.
- Removing a file or cancelling deletes the uploaded DMS file, or a timer cleans up unlinked uploads.

## UI (_UI screens, _CW blocks)
- Blocks take inputs, report outcomes through events (OnSaved(Id), OnCancel) and never navigate.
- OnParametersChanged resets the form and refreshes the data.
- Client validation uses the same rules and the same messages as the server.
- Every action button (Save, Submit, Verify, Approve, Delete) is a loading button (OutSystems UI
  `ButtonLoading`) bound to its own IsLoading flag, so a second click can't run the action twice.
- Changing any verified input resets the verification.
- Uploaders upload straight to DMS; limits match the ticket; one loading flag per uploader;
  disabled once full.
- Fields filled by a verification service are read-only.
- After success: close the block or popup, show the ticket's success message, refresh dependent lists.

## Report
- Order: Scope → ❌ Ticket gaps → 🔴 Must fix → 🟠 Should fix → 🟢 Confirm → ✅ Good.
- Each finding: what, where (module and element), why it matters, the fix. One or two sentences.
- Say what was verified in the module and what came only from the comment.
- End with the fixes as team commands (`/entity`, `/logic`, `/test`, `/block`, `/screen`, ...)
  to run one by one, smallest first, each with a **Check after:** line.
