# Example: /consume-endpoint for CheckVehiclesEligibility (Infath)

The steps (analyse, copy pattern, error handling, service action, log, verify) live in the
`/consume-endpoint` command. You only fill in the details of the new endpoint.

Copy the block below, change the values for your endpoint, and run it.

```
/consume-endpoint
Target module: Integration_ELM_IS
Reference module (read-only): Eservices_CRM_IS
  - Consumed REST API: APIGEEInfath (with OnBeforeRequest and OnAfterResponse)
  - Template service action: InfathCare/ReturnToCMC
  - Template log entity: CRMInfathCareLog

Endpoint:
  - Method name: CheckVehiclesEligibility
  - HTTP verb: POST (confirm against existing APIGEEInfath methods)
  - Path: /v1/inquires/vehicles/ownership-transfer/eligibility

Request:
{ "sequenceNumber": 123456789 }

Success response (200):
{
  "eligible": true,
  "errorCodes": [],
  "registrationExpiryDate": "2027-11-15",
  "inspectionExpiryDate": "2027-12-01",
  "insuranceExpiryDate": "2027-10-20"
}

Business-failure response (200, eligible = false):
{
  "eligible": false,
  "errorCodes": ["vehicle_has_traffic_violations", "vehicle_insurance_not_active",
                 "vehicle_mvpi_not_available"],
  "registrationExpiryDate": "2027-03-15",
  "inspectionExpiryDate": "2026-09-01",
  "insuranceExpiryDate": "2026-09-20"
}

Error response (4xx/5xx, problem+json):
{
  "type": "about:blank",
  "title": "Not Found",
  "status": 404,
  "detail": "Vehicle not found for the provided sequence number",
  "instance": "/v1/inquires/vehicles/ownership-transfer/eligibility"
}

Structures:
  - CheckVehiclesEligibilityRequest: SequenceNumber (Long Integer)
  - CheckVehiclesEligibilityResponse: Eligible (Boolean), ErrorCodes (Text List),
    RegistrationExpiryDate (Date), InspectionExpiryDate (Date), InsuranceExpiryDate (Date)
  - InfathProblemDetails: Type, Title, Status (Integer), Detail, Instance

Business error codes (static entity VehicleEligibilityErrorCode), each means the check FAILED:
  - vehicle_has_traffic_violations: Vehicle has unpaid traffic violations
  - vehicle_insurance_not_active: Vehicle insurance is not active
  - vehicle_istemarah_expired: Vehicle istemarah (registration) is expired
  - vehicle_mvpi_not_available: No valid, non-expired MVPI inspection exists
  - vehicle_status_not_transferable: Vehicle status is not transferable
  - vehicle_owner_not_alive: Individual owner is not alive (company owners skip this check)

Service action: CheckVehiclesEligibility in folder Infath/
  - Input: SequenceNumber (Long Integer) + same context inputs as ReturnToCMC
  - Output: IsSuccess, IsEligible, ErrorCodes (code + description),
    RegistrationExpiryDate, InspectionExpiryDate, InsuranceExpiryDate,
    HttpStatusCode, ErrorMessage
  - Validation: SequenceNumber > 0

Log entity: ELMInfathVehicleEligibilityLog
  - Extra fields: SequenceNumber, IsEligible
  - Index: SequenceNumber, CreatedOn
```

## Reusing it for another endpoint
Change only the details: target/reference modules, method name, verb, path, JSON samples,
structures, error codes, service action and log entity names. Leave out any section you
don't need (for example "Business error codes"); Claude derives structures from the samples.
