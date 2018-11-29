#!/usr/bin/env python3

"""convert compile_commands.json from arguments to command"""

import sys
import json

if len(sys.argv) > 2:
    INPUT_FILE = sys.argv[1]
else:
    INPUT_FILE = "compile_commands.json.bear"

if len(sys.argv) > 3:
    OUTPUT_FILE = sys.argv[1]
else:
    OUTPUT_FILE = "compile_commands.json"

NEW_JSON = list()

with open(INPUT_FILE) as fp:
    OLD_JSON = json.load(fp)
    for old_item in OLD_JSON:
        new_item = {"directory": old_item["directory"],
                    "file": old_item["file"],
                    "command": " ".join(old_item["arguments"])}
        NEW_JSON.append(new_item)

with open(OUTPUT_FILE, "w") as fp:
    json.dump(NEW_JSON, fp, indent=4)
