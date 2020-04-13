#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/git"* -rf
[[ -d "$destdir/git" ]] && exit 0

if [[ $version -ge 20 ]]; then
    $dnfyum install -y git
    echo_info "$dnfyum install global success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

rm "$destdir/git"* -rf
rm "$destdir/src/git"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/git-2.25.0.tar.gz" ]]; then
    cp "$sh_dir/downloads/git-2.25.0.tar.gz" .
else
    rm -f git-2.25.0.tar.gz*
    until wget https://github.com/git/git/archive/v2.25.0.tar.gz -O git-2.25.0.tar.gz; do
        rm -f git-2.25.0.tar.gz*
    done
fi
tar -xf git-2.25.0.tar.gz
cd "$destdir/src/git-2.25.0" || exit 1
make configure
./configure --prefix=$destdir/git-2.25.0
make all doc
make install install-doc install-html
cd ~ || exit 1
if [[ -d "$destdir/git-2.25.0" ]]; then
    rm "$destdir/src/git"* -rf
    cd "$destdir" || exit 1
    ln -s git-2.25.0 git
    echo_info "build git success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build git failed" >> "$destdir/src/install_from_src.log"
fi
