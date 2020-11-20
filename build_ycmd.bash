#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/YouCompleteMe"* -rf
#[[ -d "$destdir/YouCompleteMe" ]] && exit 0

./build_clang.bash -r "$rootdir" -d "$rootdir"
./build_gcc.bash -r "$rootdir" -d "$rootdir"

$dnfyum install python3-devel -y

cd "$destdir" || exit 1
if [[ ! -d "$destdir/YouCompleteMe" ]]; then
    if [[ -d "$sh_dir/downloads/YouCompleteMe" ]]; then
        cp -r "$sh_dir/downloads/YouCompleteMe" "$destdir/"
    else
        rm YouCompleteMe -rf
        until git clone https://github.com/Valloric/YouCompleteMe.git; do
            rm YouCompleteMe -rf
        done
    fi
fi
cd "$destdir/YouCompleteMe" || exit 1
until git submodule update --init --recursive; do
    sleep 1
done
for path in "$rootdir/clang/bin" "$rootdir/cmake/bin" "$rootdir/gcc/bin"; do
    if [[ -d "$path" ]]; then
        PATH="$path:$PATH"
    fi
done
for path in "$rootdir/gcc/lib64" "$rootdir/gcc/lib" "$rootdir/clang/lib"; do
    if [[ -d "$path" ]]; then
        LIBRARY_PATH="$path:$LIBRARY_PATH"
        LD_LIBRARY_PATH="$path:$LD_LIBRARY_PATH"
        LD_RUN_PATH="$path:$LD_RUN_PATH"
    fi
done
if [[ -f "$rootdir/gcc/bin/gcc" ]]; then
    export CC="$rootdir/gcc/bin/gcc"
fi
if [[ -f "$rootdir/gcc/bin/g++" ]]; then
    export CXX="$rootdir/gcc/bin/g++"
fi
if [[ -f "$rootdir/gcc/bin/cpp" ]]; then
    export CPP="$rootdir/gcc/bin/cpp"
fi
export PATH="${PATH%':'}"
export LIBRARY_PATH="${LIBRARY_PATH%':'}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH%':'}"
export LD_RUN_PATH="${LD_RUN_PATH%':'}"
python3 install.py --clang-completer --system-libclang

if [[ -d "$destdir/YouCompleteMe" ]]; then
    echo_info "build YouCompleteMe success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build YouCompleteMe failed" >> "$destdir/src/install_from_src.log"
fi
