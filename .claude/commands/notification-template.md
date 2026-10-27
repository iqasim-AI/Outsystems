---
description: Notification template — create one notification template (record + Excel resource + timer) in Eservices_Notification_Engine_CS
argument-hint: create <TemplateName> | <user story link> | <subject and body in AR and EN, channels SMS/Email/App>
---

# Notification template: create

Request: $ARGUMENTS

Do only this step: the template, its Excel file and its timer. Do not send the notification
from code here (that is `/logic create` or `/logic edit`) and do not run the timer.
Follow CLAUDE.md and `.claude/rules/notifications.md` (read it first), plus `environments.md`.
Work in Development only. Use the `/servicestudio-mcp-oml` skill for every change to the module.

The first word of the request is `create`. If it is missing, ask. Editing an existing template
is not covered yet: if the name already exists, stop and tell me (see "Existing template").

## What I give you
Either of these:
1. **A user story** (link or text) and, if I have one, the template name. Read the story and take
   the notification title, text, receiver and channels from it.
2. **The text itself**: subject and body in Arabic and English, the channels (SMS, Email,
   App), and the name.

If the story has no notification section, or a language, channel or placeholder value is
missing or unclear, ask. Do not invent text. If I give no name, propose one that follows the
naming rule and wait for my OK.

## The module
The module is `Eservices_Notification_Engine_CS`. Check with `listApps` that it is open in
Service Studio. If it is not, or a tool says "No module is currently open", ask me to open it
and wait. If the MCP says the session token is not valid, create a new token (I approve it in
Service Studio). Never work in another module.

## Steps

### 1. Read before writing
- Read the story (if given) with the Jira tools. If it asks me to sign in, ask me. Never enter credentials.
- Get the data model of the module. It is too big to read in chat: the tool saves it to a file.
  Run `py scripts/notification-next-id.py <that file> <TemplateName>`. It gives the highest Id and
  Order, the next free number, and whether the name is already a record.
- Check that no resource `<TemplateName>.xlsx` and no timer `Timer_<TemplateName>` exists
  (`getResourceNames`, `getTimers`). Check the name length: `Timer_` + name is 50 characters or fewer.
- If the name exists as a record, resource or timer, stop: "Existing template".

### 2. Show the plan and the Excel content, and wait for my approval
Show these two tables.

**Elements to create**

| Element | Name | Notes |
|---|---|---|
| Static entity record (`NotificationTemplate`) | `<TemplateName>` | Id = Order = next free number, Label, Is_Active |
| Resource | `<TemplateName>.xlsx` | Deploy Action = Ignore, description |
| Timer | `Timer_<TemplateName>` | Calls `General_Create_Update_NotificationContent`, argument ExcelBinary = the resource, description |

**Excel content** (sheet `NotificationContent`)

| Column | Value |
|---|---|
| Id | (empty) |
| NotificationTemplateId | the Id |
| MessagAr / MessagEn | ... |
| HTMLMessagAr / HTMLMessagEn | the same bilingual block in both columns |
| EmailSubjectAr / EmailSubjectEn | `Arabic - English` in both |
| InternalRedirectUrl | (empty) or the link |
| HasSMS / HasEmail / HasInternalNotification | TRUE / FALSE per channel |

Add: the placeholders used (the keys the sender must pass), the receiver, and any assumption
(for example `{taskId}` became `##TaskId##`).

Build the Excel file now (`scripts/build-notification-excel.py`, spec in a JSON file in a temp
folder, never in the repo) and give me the file path so I can open and check it. **Wait for my
approval.** Nothing is built in the module before that. If I change the text or the name, change
the file, show the tables again, and wait again.

### 3. Build (after approval)
Start one change with the Model API (`applyModelApiCode`, imports `OutSystems.Model.Data`), doing all of this in
**one call**:
1. Add the record to `NotificationTemplate`: Identifier, Id, Order, Label, Is_Active = True.
   Resolve the attributes by name, not by position.
2. Create the resource from the file bytes (the file as base64, from
   `scripts/build-notification-excel.py ... --base64`, and `Convert.FromBase64String(...)`;
   the sandbox cannot read files), name `<TemplateName>.xlsx`, Deploy Action = Ignore.
   Set its description.
3. Create the timer `Timer_<TemplateName>`, action `General_Create_Update_NotificationContent`,
   argument `ExcelBinary` = `Resources.<TemplateName>_xlsx.Content`, timeout 20 minutes, no schedule.
   Set its description (see `notifications.md`).
4. Read the three elements back and confirm each exists with the right name. Check that
   nothing was renamed (`Name2`), and that the timer argument points at the resource.
5. Read the validation messages. Pre-existing errors and warnings in the module are not yours
   (say so). Stop on any new error that names these elements and fix it.

Then merge the change (`omlMerge`). The merge may wait for me to accept the Compare and Merge
window in Service Studio; a long silence usually means that. Do not merge the same file twice and
do not merge an older file for the same template.

### 4. Publish and report
Ask me before publishing `Eservices_Notification_Engine_CS` to Development. Publish only when I say so.

End with a report: the Id, the three names, the channels, the placeholders, the module and the
environment, and what is **not** done:
- **Run the timer once** (Service Center, Modules, `Eservices_Notification_Engine_CS`, Timers,
  `Timer_<TemplateName>`, Wake Up). I do this: it needs my login. The template sends nothing until then.
- **Send it**: the next command, filled in with the module that owns the logic:
  `/logic create|edit <Action> in <Domain>_BL: after <event>, notify <receiver role> with
  Entities.NotificationTemplate.<TemplateName>, replacements <Placeholder> = <value>`.
  Refresh references in that module first.

## Existing template
If the record, resource or timer already exists, do not change it. Tell me which parts exist,
show what they hold now (the record Id and the timer's resource), and ask whether I want a new
name, or to change the existing text. Changing the text of an existing template is done by hand
for now: replace the resource file, publish, and run the timer again.

## Never
- Never build before I approve the Excel content.
- Never guess an Id: use the next free number from the live module.
- Never run the timer, never sign in to Service Center, never publish outside Development.
- Never change `General_Create_Update_NotificationContent` or any other template.
