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
if [[ -f "$sh_dir/downloads/gcc-9.1.0.tar.gz" ]]; then
    tar -xf "$sh_dir/downloads/gcc-9.1.0.tar.gz"
else
    rm -f gcc-9.1.0.tar.gz*
    until wget http://mirrors.ustc.edu.cn/gnu/gcc/gcc-9.1.0/gcc-9.1.0.tar.gz; do
        rm -f gcc-9.1.0.tar.gz*
    done
    tar -xf gcc-9.1.0.tar.gz
fi
cd "$destdir/src/gcc-9.1.0" || exit 1
gmp='gmp-6.1.0.tar.bz2'
mpfr='mpfr-3.1.4.tar.bz2'
mpc='mpc-1.0.3.tar.gz'
isl='isl-0.18.tar.bz2'
cp "$sh_dir/downloads/$gmp" .
cp "$sh_dir/downloads/$mpfr" .
cp "$sh_dir/downloads/$mpc" .
cp "$sh_dir/downloads/$isl" .
./contrib/download_prerequisites
mkdir "$destdir/src/gcc-9.1.0/build"
cd "$destdir/src/gcc-9.1.0/build" || exit 1
../configure --prefix="$destdir/gcc-9.1.0" --disable-multilib
make
make install
cd ~ || exit 1
if [[ -d "$destdir/gcc-9.1.0" ]]; then
    rm "$destdir/src/gcc"* -rf
    cd "$destdir" || exit 1
    ln -s gcc-9.1.0 gcc
    echo_info "build gcc success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build gcc failed" >> "$destdir/src/install_from_src.log"
fi

exit 0
