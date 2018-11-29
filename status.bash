#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name=$(basename "${BASH_SOURCE[0]}")
sh_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)
export sh_full_path="$sh_dir/$sh_name"

cd "$sh_dir" || exit 1

# git
for gd in $(find /home/lixq -type d -name .git | sort -u); do
    d=$(dirname "$gd")
    printf "========== %s %s\n" "${d}" "$(seq ${#d} 80 | xargs -i echo -n =)"
    git -C "$d" status -s
    git -C "$d" status | grep push -C 10
done

# svn
for sd in $(find /home/lixq -type d -name .svn | grep -v 'workspace.*/squid-2.6.11'); do
    d=$(dirname "$sd")
    printf "========== %s %s\n" "${d}" "$(seq ${#d} 80 | xargs -i echo -n =)"
    svn status "$d"
done

for sd in $(find /home/lixq/*workspace* -type d -name .svn | sort -u); do
    d=$(dirname "$sd")
    printf "========== %s %s\n" "${d}" "$(seq ${#d} 80 | xargs -i echo -n =)"
    svn diff "$d"
done

