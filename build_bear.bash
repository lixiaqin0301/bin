#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/Bear"* -rf
[[ -d "$destdir/Bear" ]] && exit 0

./build_cmake.bash -r "$rootdir" -d "$rootdir"

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
if [[ -d "$rootdir/cmake/bin" ]]; then
    export PATH="$rootdir/cmake/bin:$PATH"
fi
cmake -DCMAKE_INSTALL_PREFIX="$destdir/Bear" ..
make
make install
cd ~ || exit 1
if [[ -d "$destdir/Bear" ]]; then
    rm "$destdir/src/Bear"* -rf
    echo_info "build Bear success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build Bear failed" >> "$destdir/src/install_from_src.log"
fi
