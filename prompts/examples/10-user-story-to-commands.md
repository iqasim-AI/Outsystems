# Example: from user story to commands

`/story` reads the story and what already exists, then gives you the commands to run
**one by one**, with a `/test create` right after each `_BL` action. It builds nothing itself. Run each command, check the result, then run the next.

## The request
```
/story Vehicle inspection in Vehicle domain:
As an inspector I want to see the inspection requests assigned to me,
open one, record the result (Passed / Failed + notes) and submit it.
Supervisors see all requests and can reassign them to another inspector.
Acceptance criteria:
- Failed needs notes.
- A submitted inspection cannot be changed.
```

## What `/story` answers (shortened)

**Screen spec**

| Screen | Type | Data shown | Filters | Buttons | Roles |
|---|---|---|---|---|---|
| InspectionList | list | RequestNumber, Chassis, InspectionDate, Status, Inspector | Status, date range; Inspector (Supervisor only) | Open; Reassign (Supervisor) | Inspector, Supervisor |
| InspectionDetail | detail | Vehicle (read-only), Result, Notes | — | Save draft, Submit | Inspector |

**What it needs underneath**

| Layer | Module | Element | New/Edit | Why |
|---|---|---|---|---|
| Core | Vehicle_CS | InspectionStatuses, InspectionResults | New | Status filter, Result dropdown |
| Core | Vehicle_CS | InspectionRequest + CRUD | New | Both screens |
| Core | Vehicle_BL | InspectionRequest_Save | New | Save draft |
| Core | Vehicle_BL | InspectionRequest_Submit | New | Submit |
| Core | Vehicle_BL | InspectionRequest_Reassign | New | Reassign |
| End-User | Vehicle_UI | InspectionList, InspectionDetail | New | — |

No block (the form is used in one place), no service action, no API.

**Assumptions:** 1. Inspectors are OutSystems users. 2. Requests are created by another
process, not in this story. 3. Reassign is a popup on the list screen.

## The commands

**1.**
```
/entity create InspectionStatuses in Vehicle_CS (static entity):
Records: Assigned, Draft, Submitted.
Description: Status of a vehicle inspection request.
```
Check after: 3 records in the right order.

**2.**
```
/entity create InspectionResults in Vehicle_CS (static entity):
Records: Passed, Failed.
Description: Outcome of a vehicle inspection.
```
Check after: 2 records.

**3.**
```
/entity create InspectionRequest in Vehicle_CS, attributes:
- RequestNumber: Text(20), mandatory, unique — business number shown to users
- VehicleId: Vehicle Identifier, mandatory, delete rule Protect
- InspectorId: User Identifier, mandatory — inspector currently assigned
- InspectionDate: Date, mandatory
- StatusId: InspectionStatuses Identifier, mandatory, default Assigned
- ResultId: InspectionResults Identifier, optional — empty until recorded
- Notes: Text(2000), optional — mandatory when Result = Failed (checked in _BL)
- Audit attributes.
Indexes: InspectorId, StatusId, InspectionDate.
```
Check after: indexes exist; Public = Yes, Expose Read Only = Yes.

**4.**
```
/crud create InspectionRequest in Vehicle_CS
```
Check after: the 5 standard actions exist and are Public.

**5.**
```
/logic create InspectionRequest_Save in Vehicle_BL:
Standard save. Role: Inspector, and only the assigned inspector.
Reject if StatusId = Submitted: "A submitted inspection cannot be changed."
Sets StatusId = Draft.
```
Check after: an inspector cannot save a request assigned to someone else.

**5a.**
```
/test create InspectionRequest_Save in Vehicle_BL:
- Assigned inspector saves a draft: saved, status Draft
- Another inspector saves it: rejected (not assigned)
- test.norole saves it: rejected (role)
- Saving a Submitted request: rejected "A submitted inspection cannot be changed."
```
Check after: all scenarios green.

**6.**
```
/logic create InspectionRequest_Submit in Vehicle_BL:
Input: InspectionRequestId. Role: Inspector, only the assigned inspector.
Rules: status must be Draft; ResultId mandatory; Notes mandatory when Result = Failed
("Notes are required when the inspection fails").
Sets StatusId = Submitted.
```
Check after: Failed without notes raises the error.

**6a.**
```
/test create InspectionRequest_Submit in Vehicle_BL:
- Draft + Passed, no notes: submitted
- Draft + Failed + notes: submitted
- Draft + Failed, no notes: rejected "Notes are required when the inspection fails", status still Draft
- Draft, no result: rejected
- Already Submitted: rejected
- Another inspector / test.norole: rejected
```
Check after: all scenarios green.

**7.**
```
/logic create InspectionRequest_Reassign in Vehicle_BL:
Inputs: InspectionRequestId, NewInspectorId. Role: Supervisor.
Rules: status must not be Submitted; new inspector must have the Inspector role.
Sets InspectorId = NewInspectorId and StatusId = Assigned.
```
Check after: a submitted request cannot be reassigned.

**7a.**
```
/test create InspectionRequest_Reassign in Vehicle_BL:
- Supervisor reassigns an Assigned request: new inspector set, status Assigned
- Supervisor reassigns a Submitted request: rejected
- New user without the Inspector role: rejected
- test.inspector tries to reassign: rejected (role)
```
Check after: all scenarios green.

**8.**
```
/screen create InspectionList in Vehicle_UI, type: list, for InspectionRequest:
Columns: RequestNumber, Vehicle chassis, InspectionDate, Status, Inspector name.
Inspectors see only their own requests; Supervisors see all.
Filters: Status, date range; Inspector (Supervisor only).
Sort by InspectionDate (newest first).
Row click opens InspectionDetail.
Reassign button (Supervisor only, hidden when Submitted) opens a popup with an
inspector dropdown and calls InspectionRequest_Reassign (Vehicle_BL).
Roles: Inspector, Supervisor.
```
Check after: an inspector sees only their own rows; the Reassign button is hidden for inspectors.

**9.**
```
/screen create InspectionDetail in Vehicle_UI, type: detail, for InspectionRequest:
Input: InspectionRequestId.
Vehicle info read-only at the top; Result (dropdown) and Notes below.
Save draft calls InspectionRequest_Save; Submit calls InspectionRequest_Submit
(Vehicle_BL), both with confirmation messages.
When Status = Submitted the form is read-only and both buttons are hidden.
Role: Inspector.
```
Check after: a submitted inspection opens read-only.

**Test the story** (on screen, after all unit tests are green)
1. As an inspector, the list shows only your requests.
2. Open one, choose Failed, leave Notes empty, Submit: the error is shown.
3. Add notes, Submit: the status is Submitted and the form becomes read-only.
4. As a supervisor, reassign an Assigned request: it disappears from the old inspector's list.

**Out of scope:** creating inspection requests (assumption 2); notifications to the inspector.
