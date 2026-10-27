# Example: notification template

`/notification-template` creates one template in `Eservices_Notification_Engine_CS`: a record in
`NotificationTemplate`, an Excel resource and a timer. All three share one name.
Rules: `.claude/rules/notifications.md`. Make sure the module is open in Service Studio.

## Request A: from a user story
```
/notification-template create NotifyEvaluatorApologyRejected
From SI-25626, section "الإشعارات", the row "رفض الطلب". Receiver: the evaluator.
Channels: SMS, Email, App.
```

## Request B: from the text
```
/notification-template create NotifyEvaluatorApologyApproved
Channels: SMS, Email, App
Subject AR: تمت الموافقة على طلب الاعتذار
Subject EN: Apology Request Approved
Message AR: تمت الموافقة على طلب الاعتذار للمهمة {taskId}. ستتم إعادة إسناد المهمة.
Message EN: The apology request for task {taskId} has been approved. The task will be reassigned.
```
`{taskId}` in a story becomes `##TaskId##` in the file.

## What the command answers (shortened)

**Elements to create**

| Element | Name | Notes |
|---|---|---|
| Static entity record (`NotificationTemplate`) | `NotifyEvaluatorApologyRejected` | Id = Order = 755 (highest is 754), Label `Notify Evaluator Apology Request Rejected`, Is_Active |
| Resource | `NotifyEvaluatorApologyRejected.xlsx` | Deploy Action = Ignore |
| Timer | `Timer_NotifyEvaluatorApologyRejected` | `General_Create_Update_NotificationContent`, ExcelBinary = the resource |

**Excel content** (sheet `NotificationContent`)

| Column | Value |
|---|---|
| Id | (empty) |
| NotificationTemplateId | 755 |
| MessagAr | تم رفض طلب الاعتذار للمهمة ##TaskId##. السبب: ##Reason##. |
| MessagEn | The apology request for task ##TaskId## has been rejected. Reason: ##Reason##. |
| HTMLMessagAr / HTMLMessagEn | `<p dir='rtl'> Arabic </p>` + blank line + `<p dir='rtl'> English </p>` (both columns) |
| EmailSubjectAr / EmailSubjectEn | `تم رفض طلب الاعتذار - Apology Request Rejected` (both columns) |
| InternalRedirectUrl | (empty) |
| HasSMS / HasEmail / HasInternalNotification | TRUE / TRUE / TRUE |

Placeholders to pass when sending: `TaskId`, `Reason`.
The Excel file path is given so you can open it. Reply **approved**, or tell it what to change.

## After you approve
1. The command adds the record, the resource and the timer in one change, reads them back,
   checks the validation messages, and merges. Accept the Compare and Merge window in Service Studio.
2. It asks before publishing. Publish `Eservices_Notification_Engine_CS` to Development.
3. **You run the timer once** in Service Center (Wake Up). Until then the template has no text.
4. Send it from the module that owns the logic, with the command it gives you, for example:
```
/logic edit BL_RejectApologyRequest in Eservices_AssetsEvaluation_BL:
After the request is rejected, notify the evaluator with
Entities.NotificationTemplate.NotifyEvaluatorApologyRejected.
Replacements: TaskId = the task number, Reason = the rejection reason.
```
   Refresh references in that module first, so the new record is visible.

## Names the command checks
| Rule | Example |
|---|---|
| Record, resource and timer share one name | `NotifyEvaluatorApologyRejected`, `NotifyEvaluatorApologyRejected.xlsx`, `Timer_NotifyEvaluatorApologyRejected` |
| `Timer_` + name is 50 characters or fewer | name is 43 or fewer |
| Label is 65 characters or fewer | `Notify Evaluator Apology Request Rejected` |
| Id and Order are the highest + 1 | highest 754, new 755 |
| Name must be new | an existing name stops the command |
