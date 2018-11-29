#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/libtirpc"* -rf
[[ -d "$destdir/libtirpc" ]] && exit 0

$dnfyum install krb5-devel -y
rm "$destdir/libtirpc"* -rf
rm "$destdir/src/libtirpc"* -rf
mkdir -p "$destdir/src"
cd "$destdir/src" || exit 1
rm -f libtirpc-1.0.3.tar.bz2*
until wget https://jaist.dl.sourceforge.net/project/libtirpc/libtirpc/1.0.3/libtirpc-1.0.3.tar.bz2; do
	rm -f libtirpc-1.0.3.tar.bz2*
done
bzip2 -d libtirpc-1.0.3.tar.bz2
tar -xf libtirpc-1.0.3.tar

cd "$destdir/src/libtirpc-1.0.3" || exit 1
sed -i 's/des_impl.c/des_impl.c des_soft.c/g' src/Makefile.am
./configure "--prefix=$destdir/libtirpc-1.0.3"
make
make install

cd ~ || exit 1
if [[ -d "$destdir/libtirpc-1.0.3" ]]; then
    rm "$destdir/src/libtirpc"* -rf
    cd "$destdir" || exit 1
    ln -s libtirpc-1.0.3 libtirpc
    echo_info "build libtirpc success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build libtirpc failed" >> "$destdir/src/install_from_src.log"
fi
