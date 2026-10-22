---
description: LLD — create, edit or publish the Low-Level Design of one feature (Markdown → Word → Confluence)
argument-hint: create|edit|publish <Feature name> in <Domain>[: story reference, elements, or what changed]
---

# LLD: create, edit or publish

Request: $ARGUMENTS

The first word of the request is the action: `create`, `edit` or `publish`. If it is missing
or is something else, ask which one. Follow CLAUDE.md and .claude/rules/.

The LLD documents what is **built** (as-built), not what was planned. Use the OutSystems MCP
only to read. Never change a module from this command.

- **Source:** `docs/lld/<Domain>/<FeatureName>.md` — Markdown, based on `docs/lld/_template.md`.
  `<FeatureName>` is PascalCase (e.g. `VehicleInspection`).
- **Word:** `pwsh scripts/build-lld.ps1 -Path <source>` → `<FeatureName>.docx` next to it.
- **Confluence:** `pwsh scripts/publish-lld.ps1 -Path <source>` → page `<Feature name> — LLD`
  under `<Domain> — LLD` in the LLD folder.
- See `docs/lld/_sample/VehicleInspection.md` for a complete example.

## Writing rules (create and edit)
- Keep every section and its number from the template. A section that doesn't apply says
  "Not applicable." — never remove it.
- Every fact comes from the modules as they are now: names, types, lengths, inputs, rules,
  messages, roles. Never copy from the story or from memory what you can read from the module.
- Diagrams in Mermaid (```mermaid blocks): dependencies (3.2), ERD (4.1), main flow as a
  sequence diagram (5.2), screen flow (8.3). Keep them small enough to read on one page.
- Business rules and error messages are copied exactly as implemented.
- Site Properties: name and purpose only. **Never** write values of credentials, keys or
  tokens, and never personal data (national IDs, real names of citizens, phone numbers).
- English, plain and short. Tables over paragraphs.
- Do not edit the `confluencePageId` front matter line; the publish script fills it.

## create
1. **Collect.** Ask for the story reference if not given. With the MCP, find every element of
   the feature in the domain's modules (`_CS`, `_BL`, `_SL`, `_CW`, `_UI`, `_API`, `_IS`,
   `_Tests`). If it is unclear whether an element belongs to the feature, list the candidates
   and ask.
2. **Check.** For what you found, check:
   - references against the checklist in `architecture.md`
   - names against `naming.md`
   - every public element has a description
   - every `_BL` action has a test screen (`testing.md`), and its last result
   Record every problem in section 14.1 (Issues found) with the rule and a suggested fix.
   **Do not fix anything.**
3. **Plan.** Show: the file path, the elements found per section, the issues found, and
   anything you could not determine. Wait for my approval.
4. **Write** the Markdown from `docs/lld/_template.md`, version 1.0, status Draft, change log
   row "First version".
5. **Build** the Word file with `build-lld.ps1`. If it fails, fix the Markdown (usually Mermaid
   syntax) and build again.
6. **Report:** the Markdown and Word paths, the issues in 14.1, and the next step:
   review the Word file, then `/lld publish`.

## edit
Follow `.claude/rules/editing.md` where it applies, plus:
1. Read the current LLD and the modules as they are now. List the differences section by section.
2. Show the plan: sections to change (before → after), the new version number
   (1.0 → 1.1 for changes; 2.0 when the feature's scope changes), and new issues found.
   Wait for my approval.
3. Change only those sections. Update the version in the front matter and in section 1,
   set status back to Draft, and add a change log row (version, date, author, what changed).
4. Build the Word file again and report as in `create`.

## publish
Publishing is visible to the whole organisation, so it always needs confirmation.
1. Check that the Word file is newer than the Markdown; if not, run `build-lld.ps1` first.
2. Run `publish-lld.ps1 -DryRun` and show its output: the target page (create or update),
   the attachments, and the version. Ask me to confirm.
3. After I confirm, run `publish-lld.ps1` and report the page URL.
4. If the script wrote the page id into the front matter, remind me to commit the change
   (on a branch, with a pull request).

If the script reports missing settings or credentials, explain the setup in `docs/lld/README.md`
and stop. Never ask for the API token in the chat, and never write it to a file.
