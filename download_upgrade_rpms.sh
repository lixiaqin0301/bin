#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir"

filepath=$(realpath "$1")
[[ -f "$filepath" ]] || exit 1

rm -rfv /tmp/r
mkdir /tmp/r
cd /tmp/r || exit 1

awk 'BEGIN{printf "wget "} NF>4{printf "http://mirrors.ustc.edu.cn/fedora/updates/30/Everything/x86_64/Packages/%s/%s-%s.%s.rpm ",tolower(substr($1,1,1)),$1,$3,$2}' "$filepath" > 1.sh
bash 1.sh
