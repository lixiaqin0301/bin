#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/vim"* -rf
[[ -d "$destdir/vim" ]] && exit 0

if [[ $version -ge 30 ]]; then
    exit 0
fi

rm "$destdir/vim"* -rf
rm "$destdir/src/vim"* -rf
yum-builddep vim -y
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/vim-8.2.tar.bz2" ]]; then
    tar -xf "$sh_dir/downloads/vim-8.2.tar.bz2"
else
    rm -f vim-8.2.tar.bz2*
    until wget http://mirrors.ustc.edu.cn/vim/unix/vim-8.2.tar.bz2; do
        rm -f vim-8.2.tar.bz2*
    done
    tar -xf vim-8.2.tar.bz2
fi
cd "$destdir/src/vim82" || exit 1
./configure --prefix="$destdir/vim-8.2" --enable-python3interp=yes 2>&1 | tee -a "$destdir/src/install_from_src.log"
make 2>&1 | tee -a "$destdir/src/install_from_src.log"
make install 2>&1 | tee -a "$destdir/src/install_from_src.log"
cd ~ || exit 1
if [[ -d "$destdir/vim-8.2" ]]; then
    rm "$destdir/src/vim"* -rf
    cd "$destdir" || exit 1
    ln -s vim-8.2 vim
    echo_info "build vim success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build vim failed" >> "$destdir/src/install_from_src.log"
fi

