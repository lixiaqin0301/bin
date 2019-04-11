#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/Python2"* -rf
[[ -d "$destdir/Python2" ]] && exit 0

if [[ $version -ge 7 ]]; then
    $dnfyum install -y python python-pip
    echo_info "$dnfyum install python success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

rm "$destdir/Python2"* -rf
rm "$destdir/Python-2"* -rf
rm "$destdir/src/Python-2"* -rf
yum-builddep python -y
cd "$destdir/src" || exit 1
rm -f Python-2.7.16.tar.xz*
until wget https://www.python.org/ftp/python/2.7.16/Python-2.7.16.tar.xz; do
    rm -f Python-2.7.16.tar.xz*
done
xz -d Python-2.7.16.tar.xz
tar -xf Python-2.7.16.tar
mkdir "$destdir/src/Python-2.7.16/build"
cd "$destdir/src/Python-2.7.16/build" || exit 1
export LD_RUN_PATH=$destdir/Python2/lib
../configure "--prefix=$destdir/Python-2.7.16" --enable-shared
make
make install
cd ~ || exit 1
if [[ -d "$destdir/Python-2.7.16" ]]; then
    rm "$destdir/src/Python-2"* -rf
    cd "$destdir" || exit 1
    ln -s Python-2.7.16 Python2
    cd "$destdir/src" || exit 1
    if [[ -f "$destdir/downloads/get-pip.py" ]]; then
        "$destdir/Python2/bin/python" "$destdir/downloads/get-pip.py"
    else
        rm -rfv get-pip.py*
        until curl -kvs https://bootstrap.pypa.io/get-pip.py -o get-pip.py; do
            sleep 1
        done
        "$destdir/Python2/bin/python" get-pip.py
    fi
    "$destdir/Python2/bin/pip2" install robotframework
    "$destdir/Python2/bin/pip2" install robotframework-sshlibrary
    echo_info "build Python2 success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build Python2 failed" >> "$destdir/src/install_from_src.log"
fi
