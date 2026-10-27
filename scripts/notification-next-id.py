#!/usr/bin/env python3
"""Find the next free NotificationTemplate Id from a saved getDataModel result.

Used by /notification-template. getDataModel for Eservices_Notification_Engine_CS is too
big to read in chat, so the tool saves it to a file. Point this script at that file.

Usage:
    py scripts/notification-next-id.py <saved-getDataModel-file> [TemplateName ...]

Prints the highest Id and Order, the next free number, whether any Id repeats, and for each
TemplateName given whether a record with that Identifier already exists.
"""
import json
import re
import sys


def load(path):
    text = open(path, encoding="utf-8").read()
    # The MCP wraps long results in JSON: {"result": "...code..."}.
    if text.lstrip().startswith("{"):
        try:
            text = json.loads(text).get("result", text)
        except ValueError:
            pass
    return text


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    text = load(sys.argv[1])
    names = sys.argv[2:]

    start = text.find('CreateStaticEntity("NotificationTemplate")')
    if start < 0:
        sys.exit("NotificationTemplate static entity not found in that file.")
    # The entity definition lists its attributes; the variable names differ between runs.
    entity = text[start:start + 6000]
    id_var = re.search(r'var (\w+) = \w+\.CreateAttribute\("Id"\)', entity)
    order_var = re.search(r'var (\w+) = \w+\.CreateAttribute\("Order"\)', entity)
    if not id_var or not order_var:
        sys.exit("Could not find the Id and Order attributes of NotificationTemplate.")

    ids = [int(x) for x in re.findall(r'SetAttributeValue\(%s, "(\d+)"\)' % id_var.group(1), text)]
    orders = [int(x) for x in re.findall(r'SetAttributeValue\(%s, "(\d+)"\)' % order_var.group(1), text)]
    identifiers = re.findall(r'\.Identifier = "([^"]+)"', text[start:])

    print(f"Records read: {len(ids)}")
    print(f"Highest Id: {max(ids)}   Highest Order: {max(orders)}")
    print(f"Next free Id and Order: {max(max(ids), max(orders)) + 1}")
    print("Duplicate Ids: " + ("none" if len(ids) == len(set(ids)) else "YES, report it"))
    for name in names:
        print(f"Name {name}: " + ("ALREADY EXISTS" if name in identifiers else "free"))


if __name__ == "__main__":
    main()
