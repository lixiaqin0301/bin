#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/gdb"* -rf
[[ -d "$destdir/gdb" ]] && exit 0

if [[ $version -ge 40 ]]; then
    sudo $dnfyum install -y gdb
    echo_info "$dnfyum install gdb success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_python2.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/gdb"* -rf
rm "$destdir/src/gdb"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/gdb-9.1.tar.gz" ]]; then
    cp "$sh_dir/downloads/gdb-9.1.tar.gz" .
else
    rm -f gdb-9.1.tar.gz*
    until wget http://mirrors.ustc.edu.cn/gnu/gdb/gdb-9.1.tar.gz; do
        rm -f gdb-9.1.tar.gz*
    done
fi
tar -xf gdb-9.1.tar.gz
mkdir "$destdir/src/gdb-9.1/build"
cd "$destdir/src/gdb-9.1/build" || exit 1
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
if [[ -f "$rootdir/Python2/bin/python" ]]; then
    export PATH="$rootdir/Python2/bin":$PATH
fi
../configure --prefix=$destdir/gdb-9.1
make
make install
cd ~ || exit 1
if [[ -d "$destdir/gdb-9.1" ]]; then
    rm "$destdir/src/gdb"* -rf
    cd "$destdir" || exit 1
    ln -s gdb-9.1 gdb
    echo_info "build gdb success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build gdb failed" >> "$destdir/src/install_from_src.log"
fi

exit 0
