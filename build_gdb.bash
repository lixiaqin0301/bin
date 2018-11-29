#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/gdb"* -rf
[[ -d "$destdir/gdb" ]] && exit 0

if [[ $version -ge 20 ]]; then
    sudo $dnfyum install -y gdb
    echo_info "$dnfyum install gdb success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_python2.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/gdb"* -rf
rm "$destdir/src/gdb"* -rf
cd "$destdir/src" || exit 1
rm -f gdb-8.2.tar.gz*
until wget http://mirrors.ustc.edu.cn/gnu/gdb/gdb-8.2.tar.gz; do
    rm -f gdb-8.2.tar.gz*
done
tar -xf gdb-8.2.tar.gz
mkdir "$destdir/src/gdb-8.2/build"
cd "$destdir/src/gdb-8.2/build" || exit 1
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
../configure --prefix=$destdir/gdb-8.2
make
make install
cd ~ || exit 1
if [[ -d "$destdir/gdb-8.2" ]]; then
    rm "$destdir/src/gdb"* -rf
    cd "$destdir" || exit 1
    ln -s gdb-8.2 gdb
    echo_info "build gdb success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build gdb failed" >> "$destdir/src/install_from_src.log"
fi

exit 0
