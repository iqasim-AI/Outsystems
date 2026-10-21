# Example: complex business logic (_BL)

```
/logic create Order_Submit in Order_BL:
Submit a draft order for approval.

Inputs: OrderId (mandatory)
Outputs: OrderNumber, TotalAmount

Steps:
1. Get the order with Order_GetById (Order_CS).
   - Must exist, and StatusId must be Draft. Otherwise raise
     "Only draft orders can be submitted".
2. Get the order items (Aggregate on OrderItem).
   - At least 1 item; every Quantity > 0.
3. Get the customer with Customer_GetById (Customer_SL service action).
   - Customer must be Active and not blocked.
4. For each item, check stock with Inventory_CheckAvailability
   (Inventory_SL). If any item is short, raise an error listing
   the product names that are short.
5. Calculate the total:
   - Line total = Quantity x UnitPrice
   - Discount: 5% if subtotal > 10,000; 10% if > 50,000
   - VAT 15% on the amount after discount
   - Round to 2 decimals
6. If total > customer's CreditLimit, set status PendingApproval;
   otherwise set status Submitted.
7. Save with Order_Update (Order_CS): TotalAmount, DiscountAmount,
   VatAmount, StatusId, SubmittedOn, SubmittedBy.
8. Create an OrderHistory record with OrderHistory_Create (Order_CS).
9. LAST step: reserve stock with Inventory_Reserve (Inventory_SL)
   and send a notification with Notification_Send (Notification_SL).
   If Inventory_Reserve fails, set the order back to Draft and
   raise the error.

Roles: Sales, SalesManager.
```

## Why it's written this way
- **Validations first** (steps 1–4): nothing is saved if the order is invalid.
- **Server-action writes** (7–8) share one transaction and roll back together.
- **Service actions last** (9): they commit on their own and can't be rolled back.
- **Undo logic is explicit**: "set the order back to Draft".
- **Every action names its module**, so Claude adds the right references.

## Decide before building
If `Notification_Send` fails after `Inventory_Reserve` succeeds, the stock stays reserved.
Should a failed notification only be logged instead of stopping the order?
