#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/Python3"* -rf
[[ -d "$destdir/Python3" ]] && exit 0

if [[ $version -ge 20 ]]; then
    $dnfyum install -y python3
    echo_info "$dnfyum install python3 success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

rm "$destdir/Python3"* -rf
rm "$destdir/Python-3"* -rf
rm "$destdir/src/Python-3"* -rf
yum-builddep python -y
$dnfyum install openssl openssl-devel libffi libffi-devel -y
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/Python-3.7.3.tar" ]]; then
    tar -xf "$sh_dir/downloads/Python-3.7.3.tar"
else
    rm -f Python-3.7.3.tar.xz*
    until wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz; do
        rm -f Python-3.7.3.tar.xz*
    done
    xz -d Python-3.7.3.tar.xz
    tar -xf Python-3.7.3.tar
fi
mkdir "$destdir/src/Python-3.7.3/build"
cd "$destdir/src/Python-3.7.3/build" || exit 1
export LD_RUN_PATH=$destdir/Python3/lib
../configure --prefix=$destdir/Python-3.7.3 --enable-shared
make
make install
cd ~ || exit 1
if [[ -d "$destdir/Python-3.7.3" ]]; then
    rm "$destdir/src/Python-3"* -rf
    cd "$destdir" || exit 1
    ln -s Python-3.7.3 Python3
    echo_info "build Python3 success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build Python3 failed" >> "$destdir/src/install_from_src.log"
fi
