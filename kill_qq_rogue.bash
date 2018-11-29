#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

pgrep QQExternal && kill "$(pgrep QQExternal)"
pgrep kagent.exe && kill "$(pgrep kagent.exe)"
pgrep kbqsvc.exe && kill "$(pgrep kbqsvc.exe)"
pgrep tencentdl.exe && kill "$(pgrep tencentdl.exe)"
pgrep QQEIMPlatform && kill "$(pgrep QQEIMPlatform)"
