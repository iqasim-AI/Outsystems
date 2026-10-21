# Example: entity with foreign keys

Create the parent entity (`Customer`) first, then the child (`Order`).

```
/entity create Order in Order_CS, attributes:
- OrderNumber: Text(20), mandatory, unique
- OrderDate: Date, mandatory
- CustomerId: Customer Identifier (from Customer_CS), mandatory, delete rule Protect
- StatusId: OrderStatuses Identifier, mandatory, default Draft
- TotalAmount: Decimal(18,2), mandatory, default 0
- RequestId: Text(50), optional, unique
- Notes: Text(500), optional
```

## Type cheat sheet
| Need | Type |
|---|---|
| Text | `Text(50)` (always give a length) |
| Whole number | `Integer` / `Long Integer` |
| Money | `Decimal(18,2)` |
| Date / time | `Date` / `Date Time` |
| Yes / No | `Boolean` |
| Foreign key | `<Entity> Identifier` |

## Delete rules
- **Protect** (default): can't delete the parent while children exist.
- **Delete**: deleting the parent deletes its children.
- **Ignore**: keeps the children. Avoid unless you have a reason.
