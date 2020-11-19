#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/curl"* -rf
[[ -d "$destdir/curl" ]] && exit 0

./build_gcc.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/curl"* -rf
rm "$destdir/src/curl"* -rf
cd "$destdir/src" || exit 1

if [[ -f "$sh_dir/downloads/curl-7.73.0.tar.gz" ]]; then
    cp "$sh_dir/downloads/curl-7.73.0.tar.gz" .
else
    rm -f curl-7.73.0.tar.gz*
    until wget https://curl.haxx.se/download/curl-7.73.0.tar.gz; do
        rm -f curl-7.73.0.tar.gz*
    done
fi
tar -xf curl-7.73.0.tar.gz
mkdir "$destdir/src/curl-7.73.0/build"
cd "$destdir/src/curl-7.73.0/build" || exit 1
../configure --prefix=/home/lixq/toolchains/curl-7.73.0 2>&1 | tee -a "$destdir/src/install_from_src.log"
make 2>&1 | tee -a "$destdir/src/install_from_src.log"
make install 2>&1 | tee -a "$destdir/src/install_from_src.log"
cd ~ || exit 1
if [[ -d "$destdir/curl-7.73.0" ]]; then
    rm "$destdir/src/curl"* -rf
    cd "$destdir" || exit 1
    ln -s curl-7.73.0 curl
    echo_info "build curl success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build curl failed" >> "$destdir/src/install_from_src.log"
fi
