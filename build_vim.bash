#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/vim"* -rf
[[ -d "$destdir/vim" ]] && exit 0

if [[ $version -ge 20 ]]; then
    $dnfyum install -y vim
    echo_info "$dnfyum install vim success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_python3.bash -r "$rootdir" -d "$rootdir"
rm "$destdir/vim"* -rf
rm "$destdir/src/vim"* -rf
$dnfyum remove vim-enhanced vim-common -y
yum-builddep vim -y
$dnfyum install lua lua-devel ruby ruby-devel openmotif openmotif-devel -y
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/vim-8.1.tar.bz2" ]]; then
    tar -xf "$sh_dir/downloads/vim-8.1.tar.bz2"
else
    rm -f vim-8.1.tar.bz2*
    until wget http://mirrors.ustc.edu.cn/vim/unix/vim-8.1.tar.bz2; do
        rm -f vim-8.1.tar.bz2*
    done
    tar -xf vim-8.1.tar.bz2
fi
cd "$destdir/src/vim81" || exit 1
if [[ -d "$rootdir/Python3/lib/python3.8/config-3.8m-x86_64-linux-gnu" ]]; then
    python3_config_dir="$rootdir/Python3/lib/python3.8/config-3.8m-x86_64-linux-gnu"
else
    python3_config_dir=/usr/lib64/python3.8/config-3.8m-x86_64-linux-gnu
fi
[[ -d "$rootdir/Python3/bin" ]] && export PATH="$rootdir/Python3/bin:$PATH"
./configure --prefix="$destdir/vim-8.1" --enable-luainterp=yes --enable-mzschemeinterp --enable-perlinterp=yes --enable-python3interp=yes --enable-tclinterp=yes --enable-rubyinterp=yes --enable-cscope --enable-multibyte --with-features=huge --with-python3-config-dir="${python3_config_dir}"
make
make install
cd ~ || exit 1
if [[ -d "$destdir/vim-8.1" ]]; then
    rm "$destdir/src/vim"* -rf
    cd "$destdir" || exit 1
    ln -s vim-8.1 vim
    echo_info "build vim success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build vim failed" >> "$destdir/src/install_from_src.log"
fi
