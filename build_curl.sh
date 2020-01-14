#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/curl"* -rf
[[ -d "$destdir/curl" ]] && exit 0

if [[ $version -ge 20 ]]; then
    $dnfyum install -y curl
    echo_info "$dnfyum install global success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

rm "$destdir/curl"* -rf
rm "$destdir/src/curl"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/curl-7.67.0.tar.bz2" ]]; then
    cp "$sh_dir/downloads/curl-7.67.0.tar.bz2" .
else
    rm -f curl-7.67.0.tar.bz2*
    until wget https://curl.haxx.se/download/curl-7.67.0.tar.bz2; do
        rm -f curl-7.67.0.tar.bz2*
    done
fi
tar -xf curl-7.67.0.tar.bz2
mkdir "$destdir/src/curl-7.67.0/build"
cd "$destdir/src/curl-7.67.0/build" || exit 1
../configure --prefix=$destdir/curl-7.67.0
make
make install
cd ~ || exit 1
if [[ -d "$destdir/curl-7.67.0" ]]; then
    rm "$destdir/src/curl"* -rf
    cd "$destdir" || exit 1
    ln -s curl-7.67.0 curl
    echo_info "build curl success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build curl failed" >> "$destdir/src/install_from_src.log"
fi
