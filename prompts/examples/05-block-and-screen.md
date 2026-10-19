# Example: block and screens (_UI)

## Form block
```
/create-block OrderForm in Order_UI for Order:
Edit an order header: Customer (dropdown), OrderDate, Notes.
Input: OrderId (NullIdentifier = new).
Events: OnSaved (returns OrderId), OnCancel.
Save calls Order_PlaceOrder or the Order_SL save action.
```

## List screen
```
/create-screen OrderList in Order_UI, type: list, for Order:
Columns: OrderNumber, Customer name, OrderDate, Status, TotalAmount.
Search by OrderNumber or customer name; filter by Status and date range.
Sort by OrderDate (newest first). Roles: Sales, SalesManager.
```

## Detail screen
```
/create-screen OrderDetail in Order_UI, type: detail, for Order:
Input: OrderId. Use the OrderForm block.
Show order items in a table below the form.
"Submit" button calls the Order_SL submit action, visible only when Status = Draft.
Roles: Sales, SalesManager.
```
