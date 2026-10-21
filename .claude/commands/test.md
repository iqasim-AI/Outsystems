---
description: Test — create or edit BDDFramework unit tests for one _BL action or service action (in [Domain]_Tests)
argument-hint: create|edit <ActionName> in <Module>[: extra cases, or the change]
---

# Test: create or edit

Request: $ARGUMENTS

The first word of the request is the action: `create` or `edit`. If it is missing or
is something else, ask which one. Do only this step — never change the action under test.
Follow CLAUDE.md and .claude/rules/, especially `testing.md`. Work in Development only.

Tests live in `[Domain]_Tests` (application `[Domain] Tests`). If it doesn't exist, say so
and ask before creating the module and application.

## Design rules (create and edit)
- Read the action under test with the OutSystems MCP: inputs, outputs, every validation,
  business rule, role check, exception message, and every action it calls.
- Derive the scenarios from what the action **really** does, plus the extra cases in the
  request. If the request describes a rule the action doesn't implement, report it as a
  gap — don't write a test that passes against the gap.
- Cases (from `testing.md`): happy path, one per rejected rule, allowed and denied per role,
  one per error message.
- Data: created in *Given* with `TEST-` keys; AbortTransaction at the end; explicit cleanup
  when a service action is called.
- Users: `test.<role>` via `Login(UserId)` in *Given*; `Tests_EnsureTestUsers` exists or is
  created; `Logout` at the end.
- Calls to `_IS` wrappers: check the mock Site Property is set; if not, say which value is
  needed and stop.
- One test screen `<ActionName>_Tests`; step actions named after the step
  (e.g. `Given_DraftRequestForTestInspector`). Reuse existing *Given* steps in the module.

## create
1. If `<ActionName>_Tests` already exists, stop (I may want `edit`).
2. Show the plan as a table:
   \# | Scenario | Given (data + user) | When | Then (result + data state)
   plus: test users needed, mocks needed, gaps found. Wait for my approval.
3. After approval: create the steps and scenarios, publish `[Domain]_Tests` to Development,
   run the screen, and report each scenario as passed or failed. For a failure, show the
   assert message and say whether the test or the action looks wrong — do not change either
   without asking.

## edit
Follow `.claude/rules/editing.md` where it applies, plus:
- **The action under test changed** (after `/logic edit`): compare the action's current
  rules with the scenarios. List scenarios to add, change or remove, and why.
- **Adding cases**: add scenarios; don't touch the existing ones.
- **Changing an existing scenario** is allowed only when the rule itself changed. Say which
  rule changed. Never weaken an assertion just to make a test pass.
- Removing a scenario needs explicit approval.
- The plan shows the same table with a Change column (Added / Changed / Removed).
- After approval: change, publish, run the whole screen (not only the changed scenarios),
  and report the results.
