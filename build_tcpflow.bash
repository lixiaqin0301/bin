#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/tcpflow"* -rf
[[ -d "$destdir/tcpflow" ]] && exit 0

if [[ $version -ge 7 ]]; then
    $dnfyum install -y tcpflow
    echo_info "$dnfyum install tcpflow success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_boost.bash -r "$rootdir" -d "$rootdir"
yum-builddep tcpflow libpcap-devel -y
yum remove sqlite-devel -y
rm "$destdir/tcpflow"* -rf
rm "$destdir/src/tcpflow"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/tcpflow-1.5.0.tar.gz" ]]; then
    tar -xf "$sh_dir/downloads/tcpflow-1.5.0.tar.gz"
else
    rm -f tcpflow-1.5.0.tar.gz*
    until wget http://digitalcorpora.org/downloads/tcpflow/tcpflow-1.5.0.tar.gz; do
        rm -f tcpflow-1.5.0.tar.gz*
    done
    tar -xf tcpflow-1.5.0.tar.gz
fi
if [[ $version -le 5 ]]; then
    cd "$destdir/src/tcpflow-1.5.0" || exit 1
    sed -i '/^#include <pcap\/pcap.h>/c#include <pcap.h>' ./src/wifipcap/wifipcap.h
    sed -i 's/^\(.*pcap_compile([^,]*,[^,]*,\)/\1 (char *)/g' ./src/tcpflow.cpp
fi
mkdir "$destdir/src/tcpflow-1.5.0/build"
cd "$destdir/src/tcpflow-1.5.0/build" || exit 1
for path in "$rootdir/boost/include" /usr/include/cairo; do
    if [[ -d "$path" ]]; then
        C_INCLUDE_PATH="$path:$C_INCLUDE_PATH"
        CPLUS_INCLUDE_PATH="$path:$CPLUS_INCLUDE_PATH"
    fi
done
if [[ -d "$rootdir/gcc/bin" ]]; then
    PATH=$rootdir/gcc/bin:$PATH
fi
for path in "$rootdir/gcc/lib64" "$rootdir/boost/lib"; do
    LIBRARY_PATH=$path:$LIBRARY_PATH
    LD_LIBRARY_PATH=$path:$LD_LIBRARY_PATH
    LD_RUN_PATH=$path:$LD_RUN_PATH
done
export C_INCLUDE_PATH="${C_INCLUDE_PATH%':'}"
export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH%':'}"
export PATH="${PATH%':'}"
export LIBRARY_PATH="${LIBRARY_PATH%':'}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH%':'}"
export LD_RUN_PATH="${LD_RUN_PATH%':'}"
../configure --prefix="$destdir/tcpflow-1.5.0"
make
make install
cd ~ || exit 1
if [[ -d "$destdir/tcpflow-1.5.0" ]]; then
    rm "$destdir/src/tcpflow"* -rf
    cd "$destdir" || exit 1
    ln -s tcpflow-1.5.0 tcpflow
    echo_info "build tcpflow success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build tcpflow failed" >> "$destdir/src/install_from_src.log"
fi
