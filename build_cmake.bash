#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/cmake"* -rf
[[ -d "$destdir/cmake" ]] && exit 0

if [[ $version -ge 30 ]]; then
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/cmake"* -rf
rm "$destdir/src/cmake"* -rf
yum-builddep cmake -y
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/cmake-3.17.1.tar.gz" ]]; then
    cp "$sh_dir/downloads/cmake-3.17.1.tar.gz" .
else
    rm -f cmake-3.17.1.tar.gz*
    until wget https://github.com/Kitware/CMake/releases/download/v3.17.1/cmake-3.17.1.tar.gz; do
        rm -f cmake-3.17.1.tar.gz*
    done
fi
tar -xf cmake-3.17.1.tar.gz
mkdir "$destdir/src/cmake-3.17.1/build"
cd "$destdir/src/cmake-3.17.1/build" || exit 1
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
../configure --prefix="$destdir/cmake-3.17.1"
gmake
gmake install
cd ~ || exit 1
yum -y remove emacs emacs-common
if [[ -d "$destdir/cmake-3.17.1" ]]; then
    rm "$destdir/src/cmake"* -rf
    cd "$destdir" || exit 1
    ln -s cmake-3.17.1 cmake
    echo_info "build cmake success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build cmake failed" >> "$destdir/src/install_from_src.log"
fi
