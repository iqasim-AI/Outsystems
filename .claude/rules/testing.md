# Testing rules

We test with **BDDFramework** (Forge). Tests are scenarios written as Given / When / Then.
Each step is a server action that calls the code under test and checks the result with
BDDFramework's assert actions.

## What we test

| Layer | Test? | How |
|---|---|---|
| `_BL` | **Yes — main focus** | One scenario per business rule, per role (allowed and denied) and per error |
| `_SL` | Yes — the contract | The inputs and outputs other apps rely on |
| `_CS` CRUD | Lightly | Mandatory-field validation only; never re-test platform entity actions |
| `_API` | From outside | Postman/Newman collection: status codes, error codes, auth |
| `_IS` | Against a mock | Never the real provider |
| Screens | Not unit tested | Manual test steps from `/story` |

## Where tests live
- One test module per domain: `[Domain]_Tests` (e.g. `Vehicle_Tests`), in a **separate
  application** `[Domain] Tests`.
- It references `_BL`, `_SL` and `_CS` (read). Nothing references it.
- Deployed to Development and Test **only**. Never to Pre-Production or Production.
- One BDDFramework test screen per action under test, named `<ActionName>_Tests`
  (e.g. `InspectionRequest_Submit_Tests`). One scenario per case.
- Follow the structure of the BDDFramework version installed. Before creating the first
  test in a module, read an existing test module with the MCP and copy its structure.
- Test modules follow BDDFramework's structure even where it differs from `coding.md`;
  `coding.md` applies to application modules.

## Scenarios
- Scenario names say the case and the expected result:
  `Failed inspection without notes is rejected`.
- Every action under test has at least:
  1. the happy path
  2. one scenario per business rule it rejects
  3. allowed **and** denied for each role it checks
  4. one per error the action raises (check the message, not only that it failed)
- *Then* checks the result **and** the data state (e.g. "status is still Draft").
- Scenarios are independent: each one creates its own data and does not depend on order.

## Test data
- Create data in the *Given* step. Business keys start with `TEST-` (e.g. `TEST-INS-001`).
- End every scenario with **AbortTransaction**, so everything it wrote is rolled back.
- **Service actions commit on their own** and are not rolled back by AbortTransaction.
  Scenarios that call one must delete what they created in a final cleanup step.
- Never read or change real records. Never depend on data that already exists, except
  static entities.

## Test users
`_BL` actions check roles with `GetUserId()`. When tests run from a REST call or by another
developer, the user is different or anonymous, so tests need fixed users.
- Users named `test.<role>` (e.g. `test.inspector`, `test.supervisor`), one per role, plus
  `test.norole` for denied cases. When a rule checks ownership ("only the assigned
  inspector"), add a second user with the same role (`test.inspector2`).
- A setup action `Tests_EnsureTestUsers` in `[Domain]_Tests` creates them if missing and
  grants their roles. It is idempotent.
- The *Given* step switches user with the System `Login(UserId)` action. No passwords;
  Nafath/ADFS is not involved. The last step calls `Logout`.
- Test users exist only in Development and Test.

## External systems
- `_BL` actions that call an `_IS` wrapper are tested against a **mock**: in Development and
  Test, the `_IS` Site Property for the base URL points to a mock endpoint that returns the
  sample responses (success, business failure, error).
- Never call the real provider from a test.

## When tests run
LifeTime deploys but does not run tests or block a deployment. The gate is a team rule:
1. Run the domain's test suite in Development (every `<ActionName>_Tests` screen).
2. All scenarios green.
3. The feature's LLD is created or updated (`/lld create` or `/lld edit`), with the test
   results in section 12, and published (`/lld publish`).
4. Create the LifeTime deployment plan to Test.
5. Note the result (number of scenarios, all passed, LLD link) on the story or ticket.

A failing test is never deleted or weakened to make it pass. Fix the code, or, if the rule
changed, change the test in the same change and say so.
