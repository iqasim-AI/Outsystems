# Low-Level Designs (LLD)

One LLD per feature, written by `/lld create`, kept in Markdown in this folder, exported to Word
and published to Confluence.

```
docs/lld/
├── _template.md                  # the 14 sections every LLD has
├── _sample/VehicleInspection.md  # complete example
├── lld.config.json               # Confluence site, space and LLD folder (no secrets)
└── <Domain>/<FeatureName>.md     # one file per feature
```

The `.docx` files and `_build/` folders are generated and not committed. The Word file is
attached to the Confluence page.

## Workflow

| Step | Command | Result |
|---|---|---|
| 1 | `/lld create Vehicle inspection in Vehicle: SAMPLE-123` | Markdown + Word file |
| 2 | Review the Word file; fix with `/lld edit` | |
| 3 | `/lld publish Vehicle inspection in Vehicle` | Confluence page, Word attached |
| 4 | Commit the Markdown on a branch, open a pull request | |
| later | `/lld edit ...` then `/lld publish ...` | New version, same page |

## One-time setup (each developer, Windows)

```
winget install Microsoft.PowerShell
winget install JohnMacFarlane.Pandoc
winget install OpenJS.NodeJS.LTS
```

Restart the terminal after installing. Diagrams are rendered with the Edge browser already
on the machine; nothing else is downloaded. To use another browser, set `LLD_BROWSER` to its
`.exe` path.

### Confluence credentials (only for publishing)

1. Create an API token: <https://id.atlassian.com/manage-profile/security/api-tokens>
2. Save it as **user** environment variables (never in this repo, never in a chat):
   ```
   [Environment]::SetEnvironmentVariable('CONFLUENCE_EMAIL', 'you@company.com', 'User')
   [Environment]::SetEnvironmentVariable('CONFLUENCE_API_TOKEN', '<token>', 'User')
   ```
3. Restart the terminal and Claude Code.

You publish with your own account, so Confluence shows who published each version.

## Confluence settings (once, by the owner)

Fill in `lld.config.json`:

| Setting | Where to find it |
|---|---|
| `baseUrl` | `https://<your-site>.atlassian.net` |
| `spaceKey` | Space settings → Space details → Key |
| `lldFolderId` | Open the LLD folder; the number at the end of its URL |

Pages are created as `LLD folder → <Domain> — LLD → <Feature name> — LLD`. The Confluence API
can't create a page directly inside a folder, so the script creates each domain page and then
moves it into the folder. Feature pages are created under their domain page.

## Rules

- The Confluence page is generated: edit the Markdown and publish again, never the page.
- No credentials, keys, tokens or personal data in any LLD.
