#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "$BASH_SOURCE")"
sh_dir="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
sh_full_path="$sh_dir/$sh_name"

function echo_info() {
	printf "%s %s:%02d =>%s: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$sh_name" ${BASH_LINENO[0]} "${FUNCNAME[1]}" "$*"
}

# Install irony server

# Remove old irony server
rm -rf ${HOME}/.emacs.d/irony

# Get irony package path
irony_dir="$(if [[ -d "${HOME}/.emacs.d/elpa/irony-*" ]]; then cd "${HOME}/.emacs.d/elpa/irony-*"; pwd; fi)"

build_dir=$(mktemp -d)
cd $build_dir

if [[ -d /home/lixq/toolchains/gcc/lib64 && -d /home/lixq/toolchains/clang/lib && -f /home/lixq/toolchains/gcc/bin/gcc && -f /home/lixq/toolchains/gcc/bin/g++ && -d /home/lixq/toolchains/clang ]]; then
    cmake -DCMAKE_INSTALL_RPATH='/home/lixq/toolchains/gcc/lib64;/home/lixq/toolchains/clang/lib' -DCMAKE_C_COMPILER=/home/lixq/toolchains/gcc/bin/gcc -DCMAKE_CXX_COMPILER=/home/lixq/toolchains/gcc/bin/g++ -DCMAKE_PREFIX_PATH=/home/lixq/toolchains/clang -DCMAKE_INSTALL_PREFIX="${HOME}/.emacs.d/irony" "${irony_dir}/server"
else
    cmake -DCMAKE_INSTALL_PREFIX="${HOME}/.emacs.d/irony" "${irony_dir}/server"
fi
cmake --build . --use-stderr --config Release --target install

rm -rf $build_dir

exit 0
