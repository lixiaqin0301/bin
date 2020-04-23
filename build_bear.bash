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
if [[ -f "$sh_dir/downloads/Bear-2.4.3.tar.gz" ]]; then
    cp "$sh_dir/downloads/Bear-2.4.3.tar.gz" .
else
    rm -rf Bear-2.4.3.tar.gz*
    until wget https://github.com/rizsotto/Bear/archive/v2.4.3.tar.gz -O Bear-2.4.3.tar.gz; do
        rm -rf Bear-2.4.3.tar.gz*
    done
fi
tar -xf Bear-2.4.3.tar.gz
mkdir "$destdir/src/Bear-2.4.3/build"
cd "$destdir/src/Bear-2.4.3/build" || exit 1
if [[ -d "$rootdir/cmake/bin" ]]; then
    export PATH="$rootdir/cmake/bin:$PATH"
fi
cmake -DCMAKE_INSTALL_PREFIX="$destdir/Bear-2.4.3" ..
make
make install
cd ~ || exit 1
if [[ -d "$destdir/Bear-2.4.3" ]]; then
    rm "$destdir/src/Bear"* -rf
    cd "$destdir" || exit 1
    ln -s Bear-2.4.3 Bear
    echo_info "build Bear success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build Bear failed" >> "$destdir/src/install_from_src.log"
fi
