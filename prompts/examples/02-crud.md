# Example: CRUD for an entity

```
/create-crud Order in Order_CS
```

Creates in `Order_CS`:
- `Order_Create`
- `Order_Update`
- `Order_CreateOrUpdate`
- `Order_Delete`
- `Order_GetById`

To add a lookup by another field, ask for it explicitly:

```
/create-crud Order in Order_CS — also add Order_GetByRequestId
(input: RequestId Text, output: Order record, empty if not found)
```
