#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/Bear"* -rf
[[ -d "$destdir/Bear" ]] && exit 0

./build_cmake.bash -r "$rootdir" -d "$rootdir"
./build_python2.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/Bear"* -rf
rm "$destdir/src/Bear"* -rf
cd "$destdir/src" || exit 1
if [[ -d "$sh_dir/downloads/Bear" ]]; then
    cp -r "$sh_dir/downloads/Bear" "$destdir/src/"
else
    until git clone https://github.com/rizsotto/Bear.git; do
        rm -rf Bear
    done
fi
mkdir "$destdir/src/Bear/build"
cd "$destdir/src/Bear/build" || exit 1
for path in "$rootdir/cmake/bin" "$rootdir/Python2/bin"; do
    if [[ -d "$path" ]]; then
        PATH="$path:$PATH"
    fi
done
export PATH="${PATH%':'}"
PYTHON_EXECUTABLE=$(command -v python2)
[[ -x "$rootdir/Python2/bin/python2" ]] && PYTHON_EXECUTABLE="$rootdir/python2/bin/python2"
cmake -DCMAKE_INSTALL_PREFIX="$destdir/Bear" -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE ..
make
make install
cd ~ || exit 1
if [[ -d "$destdir/Bear" ]]; then
    rm "$destdir/src/Bear"* -rf
    sed -i '1c#!/usr/bin/env python2.7' "$destdir/Bear/bin/bear"
    echo_info "build Bear success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build Bear failed" >> "$destdir/src/install_from_src.log"
fi
