# Example: REST API — CheckVehiclesEligibility

Build in this order. Replace the eligibility rules with your real ones.

## 1. Consume the external system (if eligibility needs outside data)
```
/api-consume create GetVehicleStatus in Traffic_IS:
(fill in the full template from example 08; short version below)
GET {TrafficBaseUrl}/vehicles/{chassisNumber}/status
Auth: API key in header "x-api-key" from Site Property TrafficApiKey.
Response: chassisNumber, plateNumber, registrationStatus, hasTrafficViolations,
          hasBlock (Boolean), blockReason.
Wrapper: Traffic_GetVehicleStatus(ChassisNumber) -> VehicleStatus structure.
Timeout 30s, retry 2 times on timeout/5xx.
```

## 2. Business logic (_BL)
```
/logic create Vehicle_CheckEligibility in Vehicle_BL:
Check if ONE vehicle is eligible.

Inputs: ChassisNumber (Text 17, mandatory), PlateNumber (Text 10, optional)
Outputs: IsEligible (Boolean), Reasons (List of Text), VehicleId

Steps:
1. Find the vehicle with Vehicle_GetByChassisNumber (Vehicle_CS).
   If not found: IsEligible = False, reason "VEHICLE_NOT_FOUND".
2. Status must be Active (static entity VehicleStatuses).
   Otherwise reason "VEHICLE_NOT_ACTIVE".
3. Not already in an open auction: Aggregate on AuctionItem where
   VehicleId = vehicle and Auction status in (Scheduled, Open).
   Otherwise reason "ALREADY_IN_AUCTION".
4. Call Traffic_GetVehicleStatus (Traffic_IS):
   - If call fails: reason "EXTERNAL_CHECK_FAILED" (do not mark eligible).
   - If hasBlock = True: reason "VEHICLE_BLOCKED".
5. IsEligible = True only if there are no reasons.
6. Read-only: no data is written.

Collect ALL reasons (don't stop at the first failure).
```

## 3. Business logic (_BL) — batch for many vehicles
```
/logic create Vehicle_CheckEligibilityBatch in Vehicle_BL:
Input: List of VehicleRef (ChassisNumber mandatory, PlateNumber optional), max 100.
Output: List of VehicleEligibilityResult
  (chassisNumber, plateNumber, isEligible, reasons[]),
  plus Success, ErrorCode, ErrorMessage.
For each item call Vehicle_CheckEligibility (Vehicle_BL).
Remove duplicate chassis numbers first.
One failing vehicle must not fail the whole batch — return its error in reasons.
Read-only, so no transaction risk.
```

## 4. Service action (_SL) — only if other apps need the check
```
/service-action create Vehicle_CheckEligibilityBatch in Vehicle_SL:
Same inputs and outputs as Vehicle_CheckEligibilityBatch (Vehicle_BL),
using Structures, not entity records.
Calls Vehicle_CheckEligibilityBatch (Vehicle_BL). No rules here.
```

## 5. Expose the REST API (_API)
```
/api-expose create CheckVehiclesEligibility in Vehicle_API:
Add to REST API "VehicleAPI".
POST /v1/vehicles/check-eligibility
Auth: Custom — API key in header "x-api-key", validated against
      Site Property PartnerApiKeys in OnAuthentication.

Request (CheckVehiclesEligibilityRequest):
{
  "requestId": "b6f1c2e0-...",        // mandatory, max 50
  "vehicles": [                        // mandatory, 1..100 items
    { "chassisNumber": "JTDBR32E720123456", "plateNumber": "ABC 1234" }
  ]
}

Response (CheckVehiclesEligibilityResponse):
{
  "success": true,
  "errorCode": "",
  "errorMessage": "",
  "requestId": "b6f1c2e0-...",
  "summary": { "total": 2, "eligible": 1, "notEligible": 1 },
  "results": [
    { "chassisNumber": "JTDBR32E720123456", "plateNumber": "ABC 1234",
      "isEligible": true,  "reasons": [] },
    { "chassisNumber": "WDB1240821A123456", "plateNumber": "XYZ 9876",
      "isEligible": false, "reasons": ["ALREADY_IN_AUCTION", "VEHICLE_BLOCKED"] }
  ]
}

Validation: chassisNumber exactly 17 chars, letters and digits only.
Errors: 400 INVALID_INPUT, 400 LIMIT_EXCEEDED (>100), 401 UNAUTHORIZED,
        500 INTERNAL_ERROR.
Calls Vehicle_CheckEligibilityBatch (Vehicle_BL).
Log requestId, caller, count, duration. Mask nothing else needed (no personal IDs).
```

## Why it's split this way
- **Rules live in `_BL`** (one vehicle) and can be reused by screens, batch jobs and the API.
- **Batching lives in `_BL`**, so the API, screens and timers share it.
- **`_SL` only wraps it** for other apps that need the check without REST.
- **`_API` stays thin**: contract, auth, validation, HTTP codes, logging.
- **External calls are isolated in `_IS`**, with base URL and key in Settings per environment.
- **Reason codes, not text**: the caller can translate or react to each reason.
- **Read-only**: nothing is written, so retries and partial failures are safe.
