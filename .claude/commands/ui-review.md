---
description: Review an OutSystems screen, block, or theme for UI consistency and risks
argument-hint: <screen|block|theme> <target/module>: <review focus>
---

# UI review

Request: $ARGUMENTS

Review only; do not modify or publish anything unless I explicitly ask for implementation afterward. Follow `.claude/rules/ui-design.md`, `ui-theme-reference.md`, and `ui-customization.md`.

## Review steps
1. Inspect the target with OutSystems MCP and inspect relevant theme CSS and shared blocks.
2. Review:
   - theme consistency and reuse of existing classes/variables;
   - desktop/tablet/phone layout and overflow;
   - RTL/LTR behaviour;
   - form labels, validation, loading, disabled, empty, and error states;
   - keyboard/focus behaviour and accessible names;
   - global CSS leakage, duplicate declarations, specificity, and `!important`;
   - fixed sizing, page-wide `zoom`/scale hacks, and unnecessary absolute positioning;
   - possible impact on shared blocks or other screens.
3. Separate findings by severity: High, Medium, Low.
4. For each finding, provide evidence (selector/element and where observed), user impact, and a minimal suggested fix.
5. Do not invent test results. Clearly mark items that cannot be verified through MCP or source inspection.

Return a concise report with:
- Summary
- Findings (severity, evidence, impact, recommended fix)
- Screens/viewports/directions to test
- Suggested implementation order

Do not silently refactor unrelated styles.
