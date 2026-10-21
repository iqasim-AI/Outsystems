# Example: unit tests with /test

Rules: `.claude/rules/testing.md`. Tests live in `Vehicle_Tests` (application `Vehicle Tests`),
never deployed beyond Test.

## Create tests for a _BL action
```
/test create InspectionRequest_Submit in Vehicle_BL:
Also cover: a Failed result with only spaces in Notes is rejected.
```

## What Claude shows before building (plan)

| # | Scenario | Given (data + user) | When | Then (result + data state) |
|---|---|---|---|---|
| 1 | Passed inspection is submitted | `TEST-INS-001`, Draft, assigned to test.inspector; user test.inspector | Submit with Result = Passed | No error; status Submitted |
| 2 | Failed with notes is submitted | `TEST-INS-002`, Draft; test.inspector | Submit Failed + "Brake failure" | No error; status Submitted |
| 3 | Failed without notes is rejected | `TEST-INS-003`, Draft; test.inspector | Submit Failed, Notes empty | Error "Notes are required when the inspection fails"; status still Draft |
| 4 | Failed with only spaces is rejected | `TEST-INS-004`, Draft; test.inspector | Submit Failed, Notes "   " | Same error; status still Draft |
| 5 | Submit without a result is rejected | `TEST-INS-005`, Draft; test.inspector | Submit, Result empty | Error; status still Draft |
| 6 | Submitted request cannot be submitted again | `TEST-INS-006`, Submitted; test.inspector | Submit | Error; status unchanged |
| 7 | Another inspector cannot submit | `TEST-INS-007`, Draft, assigned to test.inspector2; user test.inspector | Submit | Error (not assigned) |
| 8 | User without the role cannot submit | `TEST-INS-008`, Draft; user test.norole | Submit | Error (role) |

- **Test users:** test.inspector, test.inspector2, test.norole (created by `Tests_EnsureTestUsers`).
- **Mocks:** none (no `_IS` calls).
- **Gap found:** scenario 4 — the action checks `Notes = ""` but not blank spaces, so it
  will fail until `InspectionRequest_Submit` uses `Trim(Notes) = ""`.
  Suggested fix: `/logic edit InspectionRequest_Submit in Vehicle_BL: treat Notes with only spaces as empty.`

Every scenario ends with AbortTransaction, so no test data stays in the database.

## After approval: the report
```
InspectionRequest_Submit_Tests — Vehicle_Tests (Development)
✔ 7 passed   ✘ 1 failed
✘ 4 Failed with only spaces is rejected
  Expected error "Notes are required when the inspection fails", got no error.
  The test matches the requested rule; the action looks wrong (gap above).
```

## After the logic changes
```
/test edit InspectionRequest_Submit in Vehicle_BL:
InspectionRequest_Submit now trims Notes. Re-run all scenarios.
```

## Before deploying with LifeTime
Run every `*_Tests` screen in `Vehicle_Tests` in Development. All green → create the
LifeTime deployment plan to Test, and note "Vehicle_Tests: 23 scenarios, all passed" on the story.
