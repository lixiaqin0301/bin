#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

#if ! killall -0 rdm; then
#    rm -rfv /tmp/rdm
#    mkdir /tmp/rdm
#    echo "mkdir /tmp/rdm"
#    cd /tmp/rdm || exit 1
#    setsid nohup rdm &
#fi

if ! killall -q -0 rdesktop; then
    rm /tmp/rdesktop -rfv
    mkdir /tmp/rdesktop
    echo "mkdir /tmp/rdesktop"
    cd /tmp/rdesktop || exit 1
    setsid nohup rdesktop -a 32 -g 1366x705 -r disk:myshare=/tmp/rdesktop -u "$(awk '/^win/{print $2}' "$sh_dir/../sbin/ha.txt")" -p "$(awk '/^win/{print $5}' "$sh_dir/../sbin/ha.txt")" "$(awk '/^win/{print $3}' "$sh_dir/../sbin/ha.txt")" &
fi

if ! killall -q -0 eclipse; then
    rm /tmp/eclipse -rfv
    mkdir /tmp/eclipse
    echo "mkdir /tmp/eclipse"
    cd /tmp/eclipse || exit 1
    setsid nohup eclipse &
fi
