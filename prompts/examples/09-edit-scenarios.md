# Example: edit scenarios

Every `edit` follows `.claude/rules/editing.md`: Claude reads the element, lists who uses
it, says whether the change is breaking, shows a Before | After plan and waits for approval.
Say **what** to change and **why**; Claude finds the impact.

A typical feature change goes through the layers in order: entity → CRUD → logic →
service action → block → screen → API.

## Entity: add an attribute
```
/entity edit Order in Order_CS:
Add DeliveryDate: Date, optional.
Add PriorityId: OrderPriorities Identifier (new static entity: Normal, Urgent),
  mandatory, default Normal — existing orders get Normal.
Index PriorityId (used as a filter on OrderList).
```

## CRUD: validation and a new lookup
```
/crud edit Order in Order_CS:
Validate that DeliveryDate is not before OrderDate when it is filled.
Add Order_GetByOrderNumber (input: OrderNumber Text, output: Order record, empty if not found).
```

## Logic: change a business rule
```
/logic edit Order_Submit in Order_BL:
Urgent orders (PriorityId = Urgent) skip the credit-limit check
but need DeliveryDate filled; otherwise raise "Delivery date is required for urgent orders".
```

## Service action: add an output without breaking consumers
```
/service-action edit Order_PlaceOrder in Order_SL:
Add output EstimatedDeliveryDate (Date). Callers that ignore it must keep working.
```

## Service action: breaking change → new version
```
/service-action edit Order_PlaceOrder in Order_SL:
CustomerId must be replaced by CustomerNumber (Text 20).
```
Claude should propose `Order_PlaceOrder_V2`, keep the old one working and mark it deprecated.

## Block: add a field and an optional input
```
/block edit OrderForm in Order_UI:
Add DeliveryDate (date picker) and Priority (dropdown from OrderPriorities).
Add optional input IsReadOnly (Boolean, default False) that disables all fields.
```

## Screen: add a filter and a column
```
/screen edit OrderList in Order_UI:
Add a Priority filter (dropdown) and a Priority column after Status.
Urgent rows show a red "Urgent" tag.
```

## Expose API: add a response field (non-breaking)
```
/api-expose edit CheckVehiclesEligibility in Vehicle_API:
Add "checkedOn" (datetime, ISO 8601) to each item in "results".
```

## Expose API: breaking change → v2
```
/api-expose edit CheckVehiclesEligibility in Vehicle_API:
"plateNumber" becomes mandatory and the max list size drops from 100 to 50.
```
Claude should propose `CheckVehiclesEligibilityV2` on `/v2/vehicles/check-eligibility` and keep v1.

## Consume API: the provider changed its response
```
/api-consume edit GetVehicleStatus in Traffic_IS:
The provider renamed "hasBlock" to "isBlocked" and added "blockDate" (date).
New success sample:
{ "chassisNumber": "JTDBR32E720123456", "plateNumber": "ABC 1234",
  "registrationStatus": "Active", "hasTrafficViolations": false,
  "isBlocked": true, "blockReason": "Court order", "blockDate": "2026-09-01" }
Keep Traffic_GetVehicleStatus's outputs the same for its callers; add BlockDate as a new output.
```

## Consume API: new base URL
```
/api-consume edit GetVehicleStatus in Traffic_IS:
The provider moved to a new base URL. No code change: tell me which Site Property to
update and its new value per environment.
```
