#!/usr/bin/env python3
"""Build the NotificationContent Excel file for one notification template.

Used by /notification-template. The file is the resource that
General_Create_Update_NotificationContent reads, so the sheet name and the column
order must not change.

Usage:
    py scripts/build-notification-excel.py spec.json out.xlsx [--base64]

spec.json:
{
  "templateId": 754,
  "messageAr": "...", "messageEn": "...",
  "subjectAr": "...", "subjectEn": "...",
  "sms": true, "email": true, "app": true,
  "redirectUrl": ""            # optional
}

--base64 prints the file as one base64 line (the MCP sandbox cannot read files, so the
code passed to applyModelApiCode carries the file as base64).
Needs: pip install xlsxwriter
"""
import base64
import json
import sys

import xlsxwriter

HEADERS = [
    "Id", "NotificationTemplateId", "MessagAr", "MessagEn", "HTMLMessagAr",
    "HTMLMessagEn", "EmailSubjectAr", "EmailSubjectEn", "InternalRedirectUrl",
    "HasSMS", "HasEmail", "HasInternalNotification",
]


def html(ar, en):
    # Same bilingual block in both HTML columns, Arabic first, as in the existing files.
    return f"<p dir='rtl'> {ar} </p>\n\n<p dir='rtl'> {en} </p>"


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    spec = json.load(open(sys.argv[1], encoding="utf-8"))
    out = sys.argv[2]
    body = html(spec["messageAr"], spec["messageEn"])

    wb = xlsxwriter.Workbook(out)  # xlsxwriter writes sharedStrings; some viewers show a blank sheet without it
    ws = wb.add_worksheet("NotificationContent")
    for col, name in enumerate(HEADERS):
        ws.write_string(0, col, name)
    # Id (col 0) stays empty: the engine auto-numbers it.
    ws.write_number(1, 1, int(spec["templateId"]))
    ws.write_string(1, 2, spec["messageAr"])
    ws.write_string(1, 3, spec["messageEn"])
    ws.write_string(1, 4, body)
    ws.write_string(1, 5, body)
    ws.write_string(1, 6, spec["subjectAr"])
    ws.write_string(1, 7, spec["subjectEn"])
    if spec.get("redirectUrl"):
        ws.write_string(1, 8, spec["redirectUrl"])
    ws.write_boolean(1, 9, bool(spec.get("sms")))
    ws.write_boolean(1, 10, bool(spec.get("email")))
    ws.write_boolean(1, 11, bool(spec.get("app")))
    for col, width in enumerate([6, 24, 45, 60, 60, 60, 38, 38, 22, 10, 10, 24]):
        ws.set_column(col, col, width)
    wb.close()

    if "--base64" in sys.argv:
        with open(out, "rb") as f:
            print(base64.b64encode(f.read()).decode("ascii"))


if __name__ == "__main__":
    main()
