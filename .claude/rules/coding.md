# Coding rules

- Use Aggregates first; use Advanced SQL only when an aggregate can't do it, and explain why.
- Always paginate list screens (default page size: [20]).
- Validate input on the server, not only on the client.
- Handle exceptions with our standard pattern: [describe, e.g. log + user-friendly message].
- Reuse existing actions before creating new ones; search first.
- Prefer small, incremental changes over one big change.
