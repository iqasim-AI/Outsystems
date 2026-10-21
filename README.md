# outsystems-claude

Shared Claude Code setup for our OutSystems team.
Everyone who works from this folder gets the same rules, the same OutSystems MCP
connection, and the same commands.

## What's inside

```
outsystems-claude/
├── CLAUDE.md                      # Team facts + index of the rules
├── .mcp.json                      # OutSystems MCP connection (no secrets)
├── .claude/
│   ├── rules/                     # Detailed team rules (architecture, naming, ...)
│   └── commands/                  # Team slash commands
│       ├── story.md           /story (user story → commands to run)
│       ├── entity.md          /entity create|edit
│       ├── crud.md            /crud create|edit
│       ├── logic.md           /logic create|edit
│       ├── service-action.md  /service-action create|edit
│       ├── block.md           /block create|edit
│       ├── screen.md          /screen create|edit
│       ├── api-expose.md      /api-expose create|edit
│       └── api-consume.md     /api-consume create|edit
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

Each command is a **topic** followed by an **action**: `create` for something new,
`edit` for something that already exists.

```
/entity create Order in Order_CS, attributes: ...
/entity edit Order in Order_CS: add DeliveryDate (Date, optional)
```

**Start from a user story:** `/story` reads the story and what already exists, and gives
you the commands below, filled in and in order. It builds nothing; you run them one by one.
See `prompts/examples/10-user-story-to-commands.md`.

```
/story Vehicle inspection in Vehicle domain: As an inspector I want to ...
```

Build or change a feature one small step at a time, in this order:

| Step | Command | Module |
|---|---|---|
| 1 | `/entity create\|edit` | `_CS` |
| 2 | `/crud create\|edit` | `_CS` |
| 3 | `/logic create\|edit` | `_BL` |
| 4 | `/service-action create\|edit` (only for other domains/apps) | `_SL` |
| 5 | `/block create\|edit` | `_UI` or `_CW` |
| 6 | `/screen create\|edit` | `_UI` |
| 7 | `/api-expose create\|edit` (expose an API) | `_API` |
| 8 | `/api-consume create\|edit` (external endpoint, copying an existing module's pattern) | `_IS` |

Every `edit` first lists who uses the element, says whether the change is breaking, and
shows a Before | After plan (rules in `.claude/rules/editing.md`).
See `prompts/examples/09-edit-scenarios.md` for edit requests.

Each command shows a plan first. Check it, then approve.
See `prompts/examples/` for full sample requests.

Always run `git pull` before you start, so you have the latest rules.

## Sharing what you learn

- Claude got something wrong? Add a line to **"Lessons learned"** in `.claude/rules/never-do.md`.
- Found a prompt that works well? Add it to `prompts/examples/`.
- Make changes on a branch and open a pull request. The owner reviews and merges.

## Personal settings (not shared)

- `CLAUDE.local.md`: your own notes for Claude in this folder
- `.claude/settings.local.json`: your own settings

Both files are in `.gitignore` and are never committed.

## Rules that matter most

- Development environment only. **Never Production.**
- No passwords, keys or tokens in this repo.
