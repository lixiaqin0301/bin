#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/global"* -rf
[[ -d "$destdir/global" ]] && exit 0

function gen_sys_tags() {
    for include_dir in /usr/include /usr/local/include; do
        cd $include_dir || exit 1
        include_files=$(mktemp)
        find $include_dir -type f | tee "$include_files"
        "$(command -v gtags)" -f "$include_files"
    done
    #[[ ! -d /root/.vim ]] && mkdir /root/.vim
    #[[ ! -d /home/lixq/.vim ]] && mkdir /home/lixq/.vim
    #ctags -I __THROW -I __attribute_pure__ -I __nonnull -I __attribute__ --file-scope=yes --langmap=c:+.h --languages=c,c++ --links=yes --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q -f /home/lixq/.vim/systags -R /usr/include
    #ctags -I __THROW -I __attribute_pure__ -I __nonnull -I __attribute__ --file-scope=yes --langmap=c:+.h --languages=c,c++ --links=yes --c-kinds=+p --c++-kinds=+p --fields=+iaS --extra=+q -f /home/lixq/.vim/systags -R /usr/include
}

if [[ $version -ge 20 ]]; then
    $dnfyum install -y global
    gen_sys_tags
    echo_info "$dnfyum install global success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_python3.bash -r "$destdir"
export PATH="$PATH:$rootdir/Python3/bin:$rootdir/global/bin"
yum install ctags -y

if command -v pip3; then
    "$(command -v pip3)" install pygments -y
fi

rm "$destdir/global"* -rf
rm "$destdir/src/global"* -rf
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/global-6.6.3.tar.gz" ]]; then
    cp "$sh_dir/downloads/global-6.6.3.tar.gz" .
else
    rm -f global-6.6.3.tar.gz*
    until wget http://mirrors.ustc.edu.cn/gnu/global/global-6.6.3.tar.gz; do
        rm -f global-6.6.3.tar.gz*
    done
fi
tar -xf global-6.6.3.tar.gz
mkdir "$destdir/src/global-6.6.3/build"
cd "$destdir/src/global-6.6.3/build" || exit 1
../configure --prefix=$destdir/global-6.6.3
make
make install
cd ~ || exit 1
if [[ -d "$destdir/global-6.6.3" ]]; then
    rm "$destdir/src/global"* -rf
    cd "$destdir" || exit 1
    ln -s global-6.6.3 global
    gen_sys_tags
    echo_info "build global success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build global failed" >> "$destdir/src/install_from_src.log"
fi
