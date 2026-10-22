# Example: reviewing a story's implementation

`/story-review` reads the ticket and the developer's technical comment, inspects the real
modules with the OutSystems MCP, and checks them against `.claude/rules/review.md`. It changes
nothing. It reports the findings, then gives the fixes as commands to run **one by one**.

## The request
```
/story-review <ticket link>
<technical comment>
```

## What `/story-review` answers (shortened)

**Scope**

| Layer | Module | Inspected |
|---|---|---|
| Core | `<Domain>_CS` | Yes |
| Core | `<Domain>_BL` | Yes |
| Core | `<Domain>_CW` | Yes |
| End-User | `<Domain>_UI` | No (not open) |

**❌ Ticket gaps**

| Module | Element |
|---|---|
| `<Domain>_BL` | `<Entity>_Add` |
| `<Domain>_CW` | block `<Entity>Form` |

**🔴 Must fix**

| Module | Element |
|---|---|
| `<Domain>_CS` | entity `<Entity>` |
| `<Domain>_BL` | `<Entity>_Add` |

**🟠 Should fix**

| Module | Element |
|---|---|
| `<Domain>_BL` | `<Entity>_GetHeader` |
| `<Domain>_CW` | block `<Entity>Form` |

**✅ Good**

| Module | Element |
|---|---|
| `<Domain>_BL` | `<Entity>_Add` |

## The fixes

**1.**
```
/entity edit <Entity> in <Domain>_CS
```

**2.**
```
/logic edit <Entity>_Add in <Domain>_BL
```

**2a.**
```
/test edit <Entity>_Add in <Domain>_BL
```

**3.**
```
/block edit <Entity>Form in <Domain>_CW
```

**4.**
```
/screen edit <Entity>List in <Domain>_UI
```
