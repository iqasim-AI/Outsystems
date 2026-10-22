---
description: Modernize an existing OutSystems UI without changing its business behaviour
argument-hint: <screen|block> <target/module>: <desired modernisation>
---

# UI modernize

Request: $ARGUMENTS

Goal: improve visual clarity and usability while preserving business behaviour, contracts, roles, navigation, data operations, and existing theme identity. Follow `.claude/rules/ui-design.md`, `ui-theme-reference.md`, `ui-customization.md`, and `editing.md`.

## 1. Inspect and baseline
- Use MCP to inspect the target, its parents/children, shared blocks, roles, events, actions, and current theme.
- Identify the existing behaviour that must not change.
- Find existing design patterns and theme variables/classes that can be reused.
- Identify global/shared CSS and all consumers that can be discovered.

## 2. Propose a small design plan
Include:
- Current UI issues supported by inspection.
- Proposed changes and the rationale for each.
- Before | After table.
- Explicit non-goals: no business logic, data contract, roles, navigation, or API changes unless separately requested.
- Responsive and RTL/LTR plan.
- Accessibility and interaction states.
- Regression tests and impacted consumers.

Wait for approval.

## 3. Implement after approval
- Keep the change incremental and scoped.
- Preserve existing actions, events, input/output contracts, role access, and navigation.
- Reuse theme patterns before adding custom CSS.
- Do not introduce new dependencies or frameworks.
- Do not fix unrelated legacy issues in the same change.
- If a requested visual improvement requires logic or contract changes, stop and propose that as a separate step.

## 4. Validate and report
Check representative desktop, tablet, phone, RTL and LTR states. Run TrueChange and publish to Development only after approval. Report what changed, what behaviour was preserved, which consumers were checked, and what remains unverified.
