#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/rtags"* -rf
[[ -d "$destdir/rtags" ]] && exit 0

$dnfyum install zlib-devel openssl-devel -y
./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_clang.bash -r "$rootdir" -d "$rootdir"
./build_cmake.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/rtags"* -rf
rm "$destdir/src/rtags"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/rtags-2.38.tar.gz" ]]; then
    cp "$sh_dir/downloads/rtags-2.38.tar.gz" .
else
    rm -rf rtags-2.38.tar.gz*
    until wget https://github.com/Andersbakken/rtags/releases/download/v2.38/rtags-2.38.tar.gz; do
        rm -rf rtags-2.38.tar.gz*
    done
fi
tar -xf rtags-2.38.tar.gz
mkdir "$destdir/src/rtags-2.38/build"
cd "$destdir/src/rtags-2.38/build" || exit 1
for path in "$rootdir/cmake/bin" "$rootdir/gcc/bin" "$rootdir/clang/bin"; do
    if [[ -d $path ]]; then
        PATH=$path:$PATH
    fi
done
export PATH="${PATH%':'}"
elib=""
for path in "$rootdir/gcc/lib64" "$rootdir/clang/lib"; do
    if [[ -d "$path" ]]; then
        elib="$path:$elib"
    fi
done
elib="${elib%':'}"
if [[ -x "$rootdir/gcc/bin/gcc" ]]; then
    CC="$rootdir/gcc/bin/gcc"
else
    CC=$(command -v gcc)
fi
export CC
if [[ -x "$rootdir/gcc/bin/g++" ]]; then
    CXX="$rootdir/gcc/bin/g++"
else
    CXX=$(command -v g++)
fi
export CXX
export LIBRARY_PATH=$elib
export LD_LIBRARY_PATH=$elib
export LD_RUN_RPATH=$elib
cmake -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX" -DCMAKE_LIBRARY_PATH="$elib" -DCMAKE_INSTALL_RPATH="$elib" -DCMAKE_INSTALL_PREFIX="$destdir/rtags-2.38" -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..
make
make install
cd ~ || exit 1
if [[ -d "$destdir/rtags-2.38" ]]; then
    rm "$destdir/src/rtags"* -rf
    cd "$destdir" || exit 1
    ln -s rtags-2.38 rtags
    echo_info "build RTags success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build RTags failed" >> "$destdir/src/install_from_src.log"
fi
