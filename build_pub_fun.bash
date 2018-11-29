#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"

export PATH=/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin
sudo chattr -i /etc/passwd /etc/shadow /etc/group /etc/gshadow

function echo_info() {
    printf "%s %s:%02d =>%s: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$sh_name" ${BASH_LINENO[0]} "${FUNCNAME[1]}" "$*"
}

small=true
while getopts r:fd:s o; do
    case "$o" in
        r)
            [[ -d "$OPTARG" ]] && rootdir="$(cd "$OPTARG" || exit 1; pwd)";;
        f)
            force=true;;
        d)
            [[ -d "$OPTARG" ]] && destdir="$(cd "$OPTARG" || exit 1; pwd)";;
        s)
            small=false;;
    esac
done

[[ -z "$rootdir" ]] && rootdir=/home/lixq/toolchains
[[ -z "$destdir" ]] && destdir="$rootdir"
[[ -z "$force" ]] && force=false
[[ -z "$small" ]] && small=false

if [[ ! -d "$destdir/src" ]]; then
    mkdir -p "$destdir/src"
fi

if which dnf >& /dev/null; then
    dnfyum=dnf
else
    dnfyum=yum
fi

version=$(lsb_release  -r | awk '{print $2}' | awk -F '.' '{print $1}')

