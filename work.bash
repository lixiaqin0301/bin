#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

if ! killall -q -0 rdesktop; then
    rm /tmp/rdesktop -rfv
    mkdir /tmp/rdesktop
    echo "mkdir /tmp/rdesktop"
    cd /tmp/rdesktop || exit 1
    setsid nohup rdesktop -a 32 -g 1366x705 -r disk:myshare=/tmp/rdesktop -u "$(awk '/^win/{print $2}' "$sh_dir/../sbin/ha.txt")" -p "$(awk '/^win/{print $5}' "$sh_dir/../sbin/ha.txt")" "$(awk '/^win/{print $3}' "$sh_dir/../sbin/ha.txt")" &
fi

if ! ps u -C WXWork.exe; then
    rm /tmp/wxwork -rfv
    mkdir /tmp/wxwork
    echo "mkdir /tmp/wxwork"
    cd /tmp/wxwork || exit 1
    setsid nohup wine /root/.wine/drive_c/Program\ Files\ \(x86\)/WXWork/WXWork.exe &
fi
