# Example: block and screens (_UI)

## Form block
```
/block create OrderForm in Order_UI for Order:
Edit an order header: Customer (dropdown), OrderDate, Notes.
Input: OrderId (NullIdentifier = new).
Events: OnSaved (returns OrderId), OnCancel.
Save calls Order_Save (Order_BL).
```

The block is used only by screens in `Order_UI`, so it lives there. If another module
needs it later, it moves to `Order_CW` (see `/block edit`).

## List screen
```
/screen create OrderList in Order_UI, type: list, for Order:
Columns: OrderNumber, Customer name, OrderDate, Status, TotalAmount.
Search by OrderNumber or customer name; filter by Status and date range.
Sort by OrderDate (newest first). Roles: Sales, SalesManager.
```

## Detail screen
```
/screen create OrderDetail in Order_UI, type: detail, for Order:
Input: OrderId. Use the OrderForm block.
Show order items in a table below the form.
"Submit" button calls Order_Submit (Order_BL), visible only when Status = Draft.
Roles: Sales, SalesManager.
```

## Why it's written this way
- **Screens read with aggregates** on `Order_CS` entities (read-only); no service call for reads.
- **Screens write through `Order_BL`**, the same domain's logic. `Order_SL` is for other
  domains and apps, not for `Order_UI`.
- If `Order_Save` doesn't exist yet, run `/logic create Order_Save in Order_BL` first.
