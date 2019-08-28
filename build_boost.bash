#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir"

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/boost"* -rf
[[ -d "$destdir/boost" ]] && exit 0

if [[ $version -ge 7 ]]; then
    $dnfyum install -y boost "boost-*"
    echo_info "$dnfyum install boost success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_python2.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/boost"* -rf
rm "$destdir/src/boost"* -rf
yum-builddep boost -y
yum remove cmake -y
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/boost_1_71_0.tar.gz" ]]; then
    tar -xf "$sh_dir/downloads/boost_1_71_0.tar.gz"
else
    rm -rf boost_1_71_0.tar.gz*
    until wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_71_0.tar.gz --no-check-certificate; do
        rm -rf boost_1_71_0.tar.gz*
    done
    tar -xf boost_1_71_0.tar.gz
fi
cd "$destdir/src/boost_1_71_0" || exit 1
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
    pythonexcuable="$rootdir/Python2/bin/python"
else
    pythonexcuable="$(which python)"
fi
./bootstrap.sh --with-python="$pythonexcuable" --prefix="$destdir/boost_1_71_0"
./b2
./b2 install
cd ~ || exit 1
if [[ -d "$destdir/boost_1_71_0" ]]; then
    rm "$destdir/src/boost"* -rf
    cd "$destdir" || exit 1
    ln -s boost_1_71_0 boost
    echo_info "build boost success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build boost failed" >> "$destdir/src/install_from_src.log"
fi
