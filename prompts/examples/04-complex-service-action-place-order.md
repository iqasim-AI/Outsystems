# Example: complex service action (_SL)

```
/service-action create Order_PlaceOrder in Order_SL:
Public API for other apps to place a full order in one call.

Input: OrderRequest (Structure, create in Order_SL)
  - RequestId (Text 50, mandatory) – unique id from the caller
  - CustomerId (Long Integer, mandatory)
  - Items: List of OrderItemRequest
      (ProductId Long Integer, Quantity Integer – both mandatory)
  - PaymentMethodId (Long Integer, mandatory)
  - Notes (Text 500, optional)

Output: OrderResult (Structure)
  - Success (Boolean), ErrorCode (Text), ErrorMessage (Text)
  - OrderId, OrderNumber, TotalAmount, Status

Steps:
1. Authorization: the user must have role Sales or CustomerPortal.
   A CustomerPortal user may only place orders for their own CustomerId.
2. Idempotency: call Order_GetByRequestId (Order_CS). If an order
   with this RequestId exists, return it with Success = True and
   do nothing else (prevents duplicates when the caller retries).
3. Basic input check: Items not empty. Return ErrorCode
   "INVALID_INPUT" (business rules stay in _BL).
4. Call Customer_GetSummary (Customer_SL) — if not found or
   inactive, return ErrorCode "CUSTOMER_INVALID".
5. Call Order_CreateWithItems (Order_BL) – creates the order and
   its items in ONE transaction, with RequestId. Returns OrderId.
6. Call Order_Submit (Order_BL) – validates, calculates totals,
   reserves stock.
7. Call Payment_Authorize (Payment_SL) with OrderId and TotalAmount.
8. Compensation: if step 6 or 7 fails, call Order_Cancel (Order_BL)
   for the created order (it releases reserved stock), then return
   the error. If Order_Cancel also fails, log it with OrderId as
   CRITICAL for manual follow-up.
9. Return OrderResult with Success = True.

Error handling: catch all exceptions, never throw to the caller;
map them to ErrorCode + user-friendly ErrorMessage, and log the
technical details.
```

## Why it's written this way
- **Structures, not entities**: entities can change without breaking other apps.
- **Idempotency** (step 2): a retry never creates a second order.
- **No business rules here**: discounts, VAT, stock and credit all live in `_BL`.
- **All-or-nothing in one `_BL` action** (step 5): never an order without its items.
- **Compensation** (step 8): steps 5–7 commit separately, so failures are undone explicitly.
- **Error codes**: calling apps can react without parsing text.

## Build these first
- `RequestId` attribute on the existing `Order` entity → `/entity edit`
- `Order_GetByRequestId` → `/crud edit`
- `Order_CreateWithItems`, `Order_Cancel` → `/logic create`
