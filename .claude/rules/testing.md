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

## Runner check
A test exists only if the BDDFramework runner can run it. After publishing a test screen,
call the runner (below) on Development and read the JSON result.
- An `ErrorMessage` such as "Could not find TestSuite screen", or zero scenarios counted,
  means the screen is not a valid BDDFramework test screen. The suite fails; fix the structure.
- Our apps are Reactive, so the test module is a **Mobile/Reactive module built on the
  `BDDFramework Client-Side O11` Forge component** (https://www.outsystems.com/forge/component-overview/10917/bddframework-client-side-o11),
  created from its template (`TestFlow`, `Templates`, `Common`; `Layout` already contains
  `FinalResult`). The server-side component needs a Traditional Web screen and does not work
  with a Reactive module ("Could not find TestSuite screen").
- The test module references the `_BL`/`_SL`/`_CS` module under test (added in Manage
  Dependencies; the MCP cannot add references) and the action under test must be Public.
- Structure, copied from `Template_Component_Scenario`: one block per scenario in
  `TestFlow` (`Scenario_<Name>`) holding a `BDDScenario` instance (ScenarioIdentifier,
  ScenarioDescription) with `BDDStep` instances for Given / When / Then, each wired to a
  screen action through the `NotifyRunStepLogic` event; the Then step uses the
  client-side `AssertValue`. One screen `<ActionName>_Tests` in `TestFlow`, using `Layout`,
  with the scenario blocks in `MainContent` and the **Anonymous role** (the runner calls it
  without logging in).
- Run it through the client-side runner (needs Chromium installed on the server from
  `/BDDFrameworkMobile/Welcome`; not available in personal environments):
  `GET /TestRunner_API/rest/v2/BDDTestRunner/<TestModule>/<ScreenName>` returns
  `IsSuccess`, `SuccessfulScenarios`, `FailedScenarios`, `SkippedScenarios`,
  `TestScenarioResults[]` (`ScenarioId`, `IsSuccess`, `FailureReport`), `ErrorMessage`.
  Verified on Development with `OS_AI_BDD` / `calculateTest_Tests` (4 passed; a wrong
  expected value was reported as `Expected "11" but obtained "10"`).
- Running a screen in the browser, or a custom button that calls the asserts, does not count.
- The same call lets the pipeline run the suite (Postman/Newman) and fail on `SuiteSuccess = false`.
- Test screens need the access the runner requires; set it, don't open them wider than that.
- Lesson learned: a plain screen with `AssertValue` passed in the browser but the runner
  returned "Could not find TestSuite screen" (`calculateTest_Tests`, 2026-10-23).

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
