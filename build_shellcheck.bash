#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/shellcheck"* -rf
[[ -d "$destdir/shellcheck" ]] && exit 0

if [[ $version -ge 30 ]]; then
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/shellcheck"* -rf
cd "$destdir" || exit 1

if [[ -f "$sh_dir/downloads/shellcheck-v0.7.1.linux.x86_64.tar.xz" ]]; then
    cp "$sh_dir/downloads/shellcheck-v0.7.1.linux.x86_64.tar.xz" .
else
    rm -f shellcheck-v0.7.1.linux.x86_64.tar.xz*
    until wget https://github.com/koalaman/shellcheck/releases/download/v0.7.1/shellcheck-v0.7.1.linux.x86_64.tar.xz; do
        rm -f shellcheck-v0.7.1.linux.x86_64.tar.xz*
    done
fi
tar -xf shellcheck-v0.7.1.linux.x86_64.tar.xz
if [[ -d "$destdir/shellcheck-v0.7.1" ]]; then
    rm "$destdir/src/shellcheck"* -rf
    cd "$destdir" || exit 1
    ln -s shellcheck-v0.7.1 shellcheck
    echo_info "build shellcheck success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build shellcheck failed" >> "$destdir/src/install_from_src.log"
fi
