#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/gcc"* -rf
[[ -d "$destdir/gcc" ]] && exit 0

if [[ $version -ge 20 ]]; then
    $dnfyum install gcc
    echo_info "$dnfyum install gcc success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

rm "$destdir/gcc"* -rf
rm "$destdir/src/gcc"* -rf
yum-builddep gcc -y
cd "$destdir/src" || exit 1
rm -f gcc-8.2.0.tar.gz*
until wget http://mirrors.ustc.edu.cn/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz; do
    rm -f gcc-8.2.0.tar.gz*
done
tar -xf gcc-8.2.0.tar.gz
cd "$destdir/src/gcc-8.2.0" || exit 1
cp "$sh_dir/downloads/gmp-6.1.0.tar.bz2" .
cp "$sh_dir/downloads/mpfr-3.1.4.tar.bz2" .
cp "$sh_dir/downloads/mpc-1.0.3.tar.gz" .
cp "$sh_dir/downloads/isl-0.18.tar.bz2" .
./contrib/download_prerequisites
mkdir "$destdir/src/gcc-8.2.0/build"
cd "$destdir/src/gcc-8.2.0/build" || exit 1
../configure --prefix="$destdir/gcc-8.2.0" --disable-multilib
make
make install
cd ~ || exit 1
if [[ -d "$destdir/gcc-8.2.0" ]]; then
    rm "$destdir/src/gcc"* -rf
    cd "$destdir" || exit 1
    ln -s gcc-8.2.0 gcc
    echo_info "build gcc success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build gcc failed" >> "$destdir/src/install_from_src.log"
fi

exit 0
