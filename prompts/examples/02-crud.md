# Example: CRUD for an entity

```
/crud create Order in Order_CS
```

Creates in `Order_CS`:
- `Order_Create`
- `Order_Update`
- `Order_CreateOrUpdate`
- `Order_Delete`
- `Order_GetById`

To add a lookup by another field later, edit the existing CRUD:

```
/crud edit Order in Order_CS: add Order_GetByRequestId
(input: RequestId Text, output: Order record, empty if not found)
```
