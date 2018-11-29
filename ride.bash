#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

export LD_LIBRARY_PATH=/home/lixq/toolchains/wxPython-2.8/lib
rm -rf /tmp/ride
mkdir /tmp/ride
cd /tmp/ride || exit 1
setsid nohup ride.py &
