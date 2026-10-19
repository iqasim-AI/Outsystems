# outsystems-claude

Shared Claude Code setup for our OutSystems team.
Everyone who works from this folder gets the same rules, the same OutSystems MCP
connection, and the same commands.

## What's inside

```
outsystems-claude/
├── CLAUDE.md                      # Team rules Claude reads automatically
├── .mcp.json                      # OutSystems MCP connection (no secrets)
├── .claude/
│   └── commands/                  # Team slash commands
│       ├── create-entity.md          /create-entity
│       ├── create-crud.md            /create-crud
│       ├── create-logic.md           /create-logic
│       ├── create-service-action.md  /create-service-action
│       ├── create-block.md           /create-block
│       ├── create-screen.md          /create-screen
│       ├── create-rest-api.md        /create-rest-api
│       ├── consume-rest-api.md       /consume-rest-api
│       └── consume-endpoint.md       /consume-endpoint
├── prompts/
│   └── examples/                  # Proven example requests to copy from
├── .gitignore
└── README.md
```

## First-time setup (each developer)

1. Install Claude Code and sign in with your Team account.
2. Clone this repo:
   ```
   git clone <repo-url>
   cd outsystems-claude
   ```
3. Start Claude Code from this folder:
   ```
   claude
   ```
4. Approve the `outsystems` MCP server when asked.
5. Sign in to OutSystems with **your own** account when prompted.
6. Type `/` to see the team commands.

## Daily workflow

Build a feature one small step at a time, in this order:

| Step | Command | Module |
|---|---|---|
| 1 | `/create-entity` | `_CS` |
| 2 | `/create-crud` | `_CS` |
| 3 | `/create-logic` | `_BL` |
| 4 | `/create-service-action` | `_SL` |
| 5 | `/create-block` | `_UI` |
| 6 | `/create-screen` | `Portal` |
| 7 | `/create-rest-api` (expose an API) | `_API` |
| 8 | `/consume-rest-api` (call an external API) | `_IS` |
| 9 | `/consume-endpoint` (new endpoint copying an existing module's pattern) | `_IS` |

Each command shows a plan first. Check it, then approve.
See `prompts/examples/` for full sample requests.

Always run `git pull` before you start, so you have the latest rules.

## Sharing what you learn

- Claude got something wrong? Add a line to **section 9 "Lessons learned"** in `CLAUDE.md`.
- Found a prompt that works well? Add it to `prompts/examples/`.
- Make changes on a branch and open a pull request. The owner reviews and merges.

## Personal settings (not shared)

- `CLAUDE.local.md`: your own notes for Claude in this folder
- `.claude/settings.local.json`: your own settings

Both files are in `.gitignore` and are never committed.

## Rules that matter most

- Development environment only. **Never Production.**
- No passwords, keys or tokens in this repo.
