#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

if ! ps u -C WXWork.exe; then
    rm /tmp/wxwork -rfv
    mkdir /tmp/wxwork
    echo "mkdir /tmp/wxwork"
    cd /tmp/wxwork || exit 1
    setsid nohup wine /root/.wine/drive_c/Program\ Files\ \(x86\)/WXWork/WXWork.exe &
fi
