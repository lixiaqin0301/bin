#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir"

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/FlameGraph"* -rf
[[ -d "$destdir/FlameGraph" ]] && exit 0

cd "$destdir" || exit 1
until git clone https://github.com/brendangregg/FlameGraph.git; do
    rm -rf FlameGraph*
done
