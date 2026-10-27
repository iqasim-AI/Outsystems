# Notification template rules

Use these rules when creating a notification template (`/notification-template`) and when
sending one from code. They add to `architecture.md`, `naming.md`, `coding.md` and
`environments.md`.

A **notification template** is three things that always share one name:

| Part | Where | Example |
|---|---|---|
| Static entity record | `NotificationTemplate` in `Eservices_Notification_Engine_CS` | `NotifyEvaluatorApologyRejected` |
| Excel resource | same module | `NotifyEvaluatorApologyRejected.xlsx` |
| Timer | same module | `Timer_NotifyEvaluatorApologyRejected` |

The timer calls `General_Create_Update_NotificationContent` with the Excel resource. Running
the timer once loads the text (the `NotificationContent` rows) into the database. Until it
has run, the template has no text and nothing is sent.

## Module
- Always `Eservices_Notification_Engine_CS`. If another module is named, stop and ask.
- The module must be open in Service Studio. If `listApps` shows it is not open, or a tool
  says "No module is currently open", ask the developer to open it. Never guess another module.
- Development only (`environments.md`).

## Naming
- One name for the record, the resource and the timer. The timer adds the prefix `Timer_`.
  The resource adds `.xlsx`. Nothing else changes: same spelling, same case.
- Format: `Notify<Who><What>` in PascalCase, English, no spaces or underscores
  (`NotifyEvaluatorApologyRejected`, `NotifyProcurementApologyEvaluation`).
  Who is the receiver (Evaluator, Procurement, ServiceProvider, Buyer). What is the event.
- Outsystems cuts element names at 50 characters. `Timer_` + the name must be 50 or fewer,
  so the name is 43 characters or fewer. Count it before you build.
- The record Label (the readable name) is 65 characters or fewer. English, with spaces,
  for example `Notify Evaluator Apology Request Rejected`.
- Check that the name does not exist yet as a record, resource or timer. A taken name is
  silently renamed by the platform (`Name2`), which breaks the "same name" rule. If it
  exists, stop and ask (the developer may want to reuse it).

## Id and Order
- A new record gets **max Id + 1**, and the same value for Order. Read the maximum from the
  live `NotificationTemplate` records (see the command for how). Never use a number you
  remember from an earlier chat: other developers add records too.
- Check that the Id and Order are free before you build. Never reuse or renumber a record.
- Is_Active = True.
- The `NotificationTemplateId` in the Excel file must be this same Id.

## Excel file
Sheet name `NotificationContent`. One header row and one data row. Columns, in this order:

| Column | Content |
|---|---|
| `Id` | Empty. The engine numbers it. |
| `NotificationTemplateId` | The record Id (number). |
| `MessagAr` / `MessagEn` | Plain text for SMS and the in-app notification. |
| `HTMLMessagAr` / `HTMLMessagEn` | The email body: `<p dir='rtl'> Arabic </p>` then a blank line, then `<p dir='rtl'> English </p>`. Both columns hold the same bilingual block. |
| `EmailSubjectAr` / `EmailSubjectEn` | The email subject. Both columns hold `Arabic - English`. |
| `InternalRedirectUrl` | Empty unless the request gives a link. |
| `HasSMS` / `HasEmail` / `HasInternalNotification` | `TRUE` or `FALSE` from the channels in the request. |

- Channels: SMS is `HasSMS`, Email is `HasEmail`, App (in-app) is `HasInternalNotification`.
  Set only the channels the request names. If it names none, ask.
- Placeholders use `##Name##` (for example `##TaskId##`, `##Reason##`). A story that writes
  `{taskId}` becomes `##TaskId##`. Use PascalCase and the same spelling in all four texts.
  The keys the sender passes in `Replacements` must match these names exactly.
- Use the text from the story or request word for word. Do not improve, shorten or translate it.
  If a language is missing, ask.
- Build the file with `scripts/build-notification-excel.py` (xlsxwriter). Do not edit an
  old file with openpyxl: some viewers show such a file as an empty sheet.
- The developer approves the Excel content **before** anything is built in the module.

## Building the elements (one Model API call, then one merge)
- Record: Identifier = the name, `Id`, `Order`, `Label`, `Is_Active`.
- Resource: created from the file bytes, named `<Name>.xlsx`, Deploy Action = Ignore
  (it is only read by the timer), with a description.
- Timer: `Timer_<Name>`, action `General_Create_Update_NotificationContent`, argument
  `ExcelBinary = Resources.<Name>_xlsx.Content` (the dot in the file name becomes `_`),
  timeout 20 minutes, with a description. No schedule: it is run by hand, once.
- Descriptions are written, not left empty (`coding.md`). Say what the element is for,
  the channels, and the placeholders. Example for the timer:
  `Loads the NotifyEvaluatorApologyRejected notification text (AR/EN; SMS, Email, App; placeholders ##TaskId##, ##Reason##) from the Excel resource by calling General_Create_Update_NotificationContent. Run once after publishing this module.`
- Read the new record, resource and timer back after the call. A clean answer alone does not
  prove they exist.
- Check the validation messages. Pre-existing errors and warnings in this module are not
  yours. A new error or warning that names your record, resource or timer is.

## After the build
1. Merge, then publish `Eservices_Notification_Engine_CS` to Development, when the developer
   says so.
2. **Run the timer once** in Service Center (Modules, the module, Timers, Wake Up). This needs
   a person with a Service Center login. Do not try to sign in for them.
3. Tell the developer which module sends the template and give the next command
   (`/logic create` or `/logic edit`).

## Sending the template (in the module that owns the logic)
- First refresh references in that module so the new record is visible
  (`Record X does not exist in NotificationTemplate` means it is not refreshed yet).
- Recipients by role: `Eservices_UserManagement_BL.BL_GetActiveUsersByRoleId(RoleId = Roles.<Role>)`.
- Send with `Eservices_Notification_Engine_BL.Notify_User`:
  - `UsersInfo = Users mapTo { UserId: Id, Phone: MobilePhone, Email: Email }`
  - `NotificationTemplateId = Entities.NotificationTemplate.<Name>`
  - `CreatedByRole = Entities.LC_UserRole.<Role of the person doing the action>`
  - `Replacements = [ { Key: "<Placeholder>", Value: <text> } ]` (keys as in the Excel file)
  - `Language = null`, `Attchments_DMS_Files = null`
- Place the call after the last data change and before the success result.
- `Notify_User` is a service action: it commits on its own (`architecture.md`). Say in the
  plan whether a failure should cancel the whole action or only be logged.

## Never
- Never build before the Excel content is approved.
- Never reuse an Id, a name, or an old Excel file for a new template.
- Never run the timer for the developer by signing in to Service Center.
- Never publish to Test, Pre-Production or Production.
- Never change `General_Create_Update_NotificationContent` or other templates.

# Lessons learned (notifications)

- The MCP session token stops working when Service Studio restarts. Ask for a new one.
  A change file in the temp folder (`...\ServiceStudio.MCPServer\...-out.oml`) is deleted on
  restart, so rebuild instead of looking for it.
- `omlMerge` waits for the developer to accept the Compare and Merge window. A long silence
  usually means the window is waiting, not that the call failed.
- A change file that was never merged must not be merged later if the same elements were
  built again: it creates duplicates.
