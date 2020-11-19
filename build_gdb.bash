#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/gdb"* -rf
[[ -d "$destdir/gdb" ]] && exit 0

./build_gcc.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/gdb"* -rf
rm "$destdir/src/gdb"* -rf
cd "$destdir/src" || exit 1

if [[ -f "$sh_dir/downloads/gdb-10.1.tar.gz" ]]; then
    cp "$sh_dir/downloads/gdb-10.1.tar.gz" .
else
    rm -f gdb-10.1.tar.gz*
    until wget http://mirrors.ustc.edu.cn/gnu/gdb/gdb-10.1.tar.gz; do
        rm -f gdb-10.1.tar.gz*
    done
fi
tar -xf gdb-10.1.tar.gz
mkdir "$destdir/src/gdb-10.1/build"
cd "$destdir/src/gdb-10.1/build" || exit 1
if [[ -f "$rootdir/gcc/bin/gcc" ]]; then
    export CC="$rootdir/gcc/bin/gcc"
fi
if [[ -f "$rootdir/gcc/bin/g++" ]]; then
    export CXX="$rootdir/gcc/bin/g++"
fi
if [[ -f "$rootdir/gcc/bin/cpp" ]]; then
    export CPP="$rootdir/gcc/bin/cpp"
fi
if [[ -d "$rootdir/gcc/lib64" ]]; then
    export LIBRARY_PATH="$rootdir/gcc/lib64"
    export LD_LIBRARY_PATH="$rootdir/gcc/lib64"
    export LD_RUN_PATH="$rootdir/gcc/lib64"
fi
../configure --prefix=$destdir/gdb-10.1 2>&1 | tee -a "$destdir/src/install_from_src.log"
make 2>&1 | tee -a "$destdir/src/install_from_src.log"
make install 2>&1 | tee -a "$destdir/src/install_from_src.log"
cd ~ || exit 1
if [[ -d "$destdir/gdb-10.1" ]]; then
    rm "$destdir/src/gdb"* -rf
    cd "$destdir" || exit 1
    ln -s gdb-10.1 gdb
    echo_info "build gdb success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build gdb failed" >> "$destdir/src/install_from_src.log"
fi
