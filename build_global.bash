#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/global"* -rf
[[ -d "$destdir/global" ]] && exit 0

if [[ $version -ge 30 ]]; then
    exit 0
fi

yum install ctags python36-pygments -y
ln -s /usr/bin/pygmentize-3.6 /usr/bin/pygmentize

rm "$destdir/global"* -rf
rm "$destdir/src/global"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/global-6.6.5.tar.gz" ]]; then
    cp "$sh_dir/downloads/global-6.6.5.tar.gz" .
else
    rm -f global-6.6.5.tar.gz*
    until wget http://mirrors.ustc.edu.cn/gnu/global/global-6.6.5.tar.gz; do
        rm -f global-6.6.5.tar.gz*
    done
fi
tar -xf global-6.6.5.tar.gz
mkdir "$destdir/src/global-6.6.5/build"
cd "$destdir/src/global-6.6.5/build" || exit 1
../configure --prefix=$destdir/global-6.6.5
make
make install
cd ~ || exit 1
if [[ -d "$destdir/global-6.6.5" ]]; then
    rm "$destdir/src/global"* -rf
    cd "$destdir" || exit 1
    ln -s global-6.6.5 global
    echo_info "build global success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build global failed" >> "$destdir/src/install_from_src.log"
fi
