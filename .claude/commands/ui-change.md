---
description: Plan and implement a focused OutSystems UI or theme change
argument-hint: <screen|block|theme> <target/module>: <desired visual or interaction change>
---

# UI change

Request: $ARGUMENTS

Use `.claude/rules/ui-design.md`, `ui-theme-reference.md`, and `ui-customization.md` plus all relevant existing team rules. Work in Development only.

## 1. Inspect
- Use the OutSystems MCP to inspect the named target, its parent layout, relevant shared blocks, and current theme.
- Search for existing styles, variables, and patterns before proposing new CSS.
- Identify whether the target uses a shared block or global selector and list the consumers you can discover.
- If the target is ambiguous or the live theme differs from the reference snapshot, ask a focused question or use the live theme as source of truth.

## 2. Plan before changing anything
Show:
- Target module and exact screen/block/theme selector(s).
- Existing pattern(s) and theme variables/classes to reuse.
- Before | After table.
- Whether the change is local, shared, or global.
- Desktop/tablet/phone and RTL/LTR impact.
- Accessibility and interaction states to verify.
- Regression risks and test plan.

Wait for approval before implementation.

## 3. Implement after approval
- Make only the requested change.
- Reuse existing styles; create a new class only when no suitable existing pattern exists.
- Scope CSS to the smallest stable component or screen boundary.
- Do not introduce page-wide zoom/scale hacks, broad selectors, or unverified theme tokens.
- Do not add new server logic as part of a visual-only change. If required logic is missing, stop and identify the existing command to run first.
- For edits, follow `.claude/rules/editing.md`.

## 4. Validate and report
- Check desktop, tablet, phone, RTL and LTR as applicable.
- Check focus, hover, active, disabled, loading, validation, and empty states as applicable.
- Run TrueChange and publish to Development only, following dependency order.
- Report changed selectors/elements, module(s), environment, checks performed, and any unverified consumers.
