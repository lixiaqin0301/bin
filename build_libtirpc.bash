#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/libtirpc"* -rf
[[ -d "$destdir/libtirpc" ]] && exit 0

dnf install krb5-devel -y
rm "$destdir/libtirpc"* -rf
rm "$destdir/src/libtirpc"* -rf
mkdir -p "$destdir/src"
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/libtirpc-1.2.5.tar.bz2" ]]; then
    cp "$sh_dir/downloads/libtirpc-1.2.5.tar.bz2" .
else
    rm -f libtirpc-1.2.5.tar.bz2*
    until wget https://jaist.dl.sourceforge.net/project/libtirpc/libtirpc/1.2.5/libtirpc-1.2.5.tar.bz2; do
        rm -f libtirpc-1.2.5.tar.bz2*
    done
fi
bzip2 -d libtirpc-1.2.5.tar.bz2
tar -xf libtirpc-1.2.5.tar

cd "$destdir/src/libtirpc-1.2.5" || exit 1
#sed -i "s,1\.15,1.16," configure
#sed -i "s,1\.15,1.16," aclocal.m4
#sed -i 's/des_impl.c/des_impl.c des_soft.c/g' src/Makefile.am
./configure --enable-authdes "--prefix=$destdir/libtirpc-1.2.5"
make
make install

cd ~ || exit 1
if [[ -d "$destdir/libtirpc-1.2.5" ]]; then
    #rm "$destdir/src/libtirpc"* -rf
    cd "$destdir" || exit 1
    ln -s libtirpc-1.2.5 libtirpc
    echo_info "build libtirpc success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build libtirpc failed" >> "$destdir/src/install_from_src.log"
fi
