#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir"

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/zsh"* -rf
[[ -d "$destdir/zsh" ]] && exit 0

if [[ $version -ge 7 ]]; then
    $dnfyum install -y zsh
    echo_info "$dnfyum install zsh success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

yum-builddep zsh -y
rm "$destdir/zsh"* -rf
rm "$destdir/src/zsh"* -rf
cd "$destdir/src" || exit 1
rm -f zsh-5.5.1.tar.xz*
until wget ftp://ftp.zsh.org/zsh/zsh-5.5.1.tar.xz; do
    rm -f zsh-5.5.1.tar.xz*
done
xz -d zsh-5.5.1.tar.xz
tar -xf zsh-5.5.1.tar
mkdir "$destdir/src/zsh-5.5.1/build"
cd "$destdir/src/zsh-5.5.1/build" || exit 1
../configure --prefix="$destdir/zsh-5.5.1"
make
make install
cd ~ || exit 1
if [[ -d "$destdir/zsh-5.5.1" ]]; then
    rm "$destdir/src/zsh"* -rf
    cd "$destdir" || exit 1
    ln -s zsh-5.5.1 zsh
    echo_info "build zsh success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build zsh failed" >> "$destdir/src/install_from_src.log"
fi
