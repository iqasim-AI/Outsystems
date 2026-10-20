# Naming conventions

- Modules: `[Domain]_[Layer]` (e.g. `Customer_CS`, `Customer_BL`, `Customer_SL`, `Customer_UI`)
  - Suffixes: `_CS` core/CRUD, `_BL` business logic, `_SL` service layer, `_API` exposed REST, `_UI` end-user, `_IS` integration, `_Th` theme
- REST methods: PascalCase name (`CheckVehiclesEligibility`); URL kebab-case and versioned (`/v1/vehicles/check-eligibility`); JSON fields camelCase
- Entities: singular, PascalCase (`Customer`, `OrderItem`)
- Attributes: PascalCase; foreign keys end with `Id` (`CustomerId`)
- Server actions: verb first (`Customer_Create`, `Order_GetById`)
- Client actions: prefix with `On` for events (`OnSaveClick`)
- Screens: PascalCase noun (`CustomerList`, `CustomerDetail`)
- Static entities: plural (`OrderStatuses`)
