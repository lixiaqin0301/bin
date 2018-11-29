#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir"

. ./build_pub_fun.bash

if which dnf; then
    dnfyum=dnf
else
    dnfyum=yum
fi

sudo $dnfyum install -y gcc python mono-devel git gcc-c++ automake autoconf cairo-devel libpcap-devel zlib-devel redhat-rpm-config kernel-devel
if [[ $version -le 5 ]]; then
    yum remove openssl-devel -y
    yum install openssl openssl101e openssl101e-devel -y
    ln -sf /usr/include/openssl101e/openssl /usr/include/openssl
    ln -sf /usr/lib64/openssl101e/libcrypto.so /usr/lib64/libcrypto.so
    ln -sf /usr/lib64/openssl101e/libssl.so  /usr/lib64/libssl.so
    ln -sf /usr/lib64/pkgconfig/libcrypto101e.pc /usr/lib64/pkgconfig/libcrypto.pc
    ln -sf /usr/lib64/pkgconfig/libssl101e.pc /usr/lib64/pkgconfig/libssl.pc
    ln -sf /usr/lib64/pkgconfig/openssl101e.pc /usr/lib64/pkgconfig/openssl.pc
    ln -sf /usr/lib/openssl101e/libcrypto.so /usr/lib/libcrypto.so
    ln -sf /usr/lib/openssl101e/libssl.so  /usr/lib/libssl.so
    ln -sf /usr/lib/pkgconfig/libcrypto101e.pc /usr/lib/pkgconfig/libcrypto.pc
    ln -sf /usr/lib/pkgconfig/libssl101e.pc /usr/lib/pkgconfig/libssl.pc
    ln -sf /usr/lib/pkgconfig/openssl101e.pc /usr/lib/pkgconfig/openssl.pc
fi
[[ $version -ge 6 ]] && sudo $dnfyum install -y bats tcpflow
[[ $version -ge 7 ]] && sudo $dnfyum install -y boost "boost-*" ShellCheck ctags
[[ $version -ge 20 ]] && sudo $dnfyum install -y cmake clang "clang-*" llvm "llvm-*" python3 global vim-X11 python3-flake8 emacs zsh python-devel python3-devel libattr-devel cups-devel wmctrl

if which pip3; then
    sudo -H pip3 install pygments
    [[ $version -le 7 ]] && sudo -H pip3 install flake8
fi

params=("$@")
function will_build() {
    for param in "${params[@]}"; do
        if [[ "$param" == -"$*" ]]; then
            return 1
        fi
    done
    for param in "${params[@]}"; do
        if [[ "$param" == "$*" ]]; then
            return 0
        fi
    done
    for param in "${params[@]}"; do
        if [[ "$param" == all ]]; then
            return 0
        fi
    done
    return 1
}

rootdir=/home/lixq/toolchains
mkdir -p $rootdir/src
> $rootdir/src/install_from_src.log

extrapath=()
extramanpath=()
extrainfopath=()
extragtagslibpath=()

# gcc
if will_build gcc; then
    ./build_gcc.bash -r "$rootdir"
fi
if [[ -d $rootdir/gcc/bin ]]; then
    extrapath+=($rootdir/gcc/bin)
fi
if [[ -d $rootdir/gcc/share/man ]]; then
    extramanpath+=($rootdir/gcc/share/man)
fi
if [[ -d $rootdir/gcc/share/info ]]; then
    extrainfopath+=($rootdir/gcc/share/info)
fi

# cmake
if will_build cmake; then
    ./build_cmake.bash -r "$rootdir"
fi
if [[ -d $rootdir/cmake/bin ]]; then
    extrapath+=($rootdir/cmake/bin)
fi

# Python3
if will_build python3; then
    ./build_python3.bash -r "$rootdir"
fi
if [[ -d $rootdir/Python3/bin ]]; then
    extrapath+=($rootdir/Python3/bin)
fi
if [[ -d $rootdir/Python3/share/man ]]; then
    extramanpath+=($rootdir/Python3/share/man)
fi

# Python 2
if will_build python2; then
    ./build_python2.bash -r "$rootdir"
fi
if [[ -d $rootdir/Python2/bin ]]; then
    extrapath+=($rootdir/Python2/bin)
fi
if [[ -d $rootdir/Python2/share/man ]]; then
    extramanpath+=($rootdir/Python2/share/man)
fi

# clang
if will_build clang; then
    ./build_clang.bash -r "$rootdir"
fi
if [[ -d $rootdir/clang/bin ]]; then
    extrapath+=($rootdir/clang/bin)
fi
if [[ -d $rootdir/clang/share/man ]]; then
    extramanpath+=($rootdir/clang/share/man)
fi

# boost
if will_build boost; then
    ./build_boost.bash -r "$rootdir"
fi

# global
if will_build global; then
    ./build_global.bash -r "$rootdir"
fi
if [[ -d $rootdir/global/bin ]]; then
    extrapath+=($rootdir/global/bin)
fi
if [[ -d $rootdir/global/share/man ]]; then
    extramanpath+=($rootdir/global/share/man)
fi
if [[ -d $rootdir/global/share/info ]]; then
    extrainfopath+=($rootdir/global/share/info)
fi
extragtagslibpath+=(/usr/include /usr/local/include)

# vim
if will_build vim; then
    ./build_vim.bash -r "$rootdir"
fi
if [[ -d $rootdir/vim/bin ]]; then
    extrapath+=($rootdir/vim/bin)
fi
if [[ -d $rootdir/vim/share/man ]]; then
    extramanpath+=($rootdir/vim/share/man)
fi

# emacs
if will_build emacs; then
    ./build_emacs.bash -r "$rootdir"
fi
if [[ -d $rootdir/emacs/bin ]]; then
    extrapath+=($rootdir/emacs/bin)
fi
if [[ -d $rootdir/emacs/share/man ]]; then
    extramanpath+=($rootdir/emacs/share/man)
fi
if [[ -d $rootdir/emacs/share/info ]]; then
    extrainfopath+=($rootdir/emacs/share/info)
fi

# zsh
if will_build zsh; then
    ./build_zsh.bash -r "$rootdir"
fi
if [[ -d $rootdir/zsh/bin ]]; then
    extrapath+=($rootdir/zsh/bin)
fi
if [[ -d $rootdir/zsh/share/man ]]; then
    extramanpath+=($rootdir/zsh/share/man)
fi

# tcpflow
if will_build tcpflow; then
    ./build_tcpflow.bash -r "$rootdir"
fi
if [[ -d $rootdir/tcpflow/bin ]]; then
    extrapath+=($rootdir/tcpflow/bin)
fi
if [[ -d $rootdir/tcpflow/share/man ]]; then
    extramanpath+=($rootdir/tcpflow/share/man)
fi

# bashdb
if will_build bashdb; then
    ./build_bashdb.bash -r "$rootdir"
fi
if [[ -d $rootdir/bashdb/bin ]]; then
    extrapath+=($rootdir/bashdb/bin)
fi
if [[ -d $rootdir/bashdb/share/man ]]; then
    extramanpath+=($rootdir/bashdb/share/man)
fi
if [[ -d $rootdir/bashdb/share/info ]]; then
    extrainfopath+=($rootdir/bashdb/share/info)
fi

# Bear
if will_build bear; then
    ./build_bear.bash -r "$rootdir"
fi
if [[ -d $rootdir/Bear/bin ]]; then
    extrapath+=($rootdir/Bear/bin)
fi
if [[ -d $rootdir/Bear/share/man ]]; then
    extramanpath+=($rootdir/Bear/share/man)
fi

# RTags
if will_build rtags; then
    ./build_rtags.bash -r "$rootdir"
fi
if [[ -d $rootdir/rtags/bin ]]; then
    extrapath+=($rootdir/rtags/bin)
fi
if [[ -d $rootdir/rtags/share/man ]]; then
    extramanpath+=($rootdir/rtags/share/man)
fi

# FlameGraph
if will_build FlameGraph; then
    ./build_flamegraph.bash -r "$rootdir"
    extrapath+=($rootdir/FlameGraph)
fi

# vim_lixq_config
if will_build vim_lixq_config; then
    ./build_vim_lixq_config.bash -r "$rootdir"
fi

# ycmd
if will_build ycmd; then
    ./build_ycmd.bash -r "$rootdir"
fi

# oh_my_zsh
if will_build oh_my_zsh; then
    ./build_oh_my_zsh.bash -r "$rootdir"
fi

# jdk
if [[ -d $rootdir/jdk/bin ]]; then
    extrapath+=($rootdir/jdk/bin)
fi
if [[ -d $rootdir/jdk/jre/bin ]]; then
    extrapath+=($rootdir/jdk/jre/bin)
fi
if [[ -d $rootdir/jdk/man ]]; then
    extramanpath+=($rootdir/jdk/man)
fi

# eclipse
if [[ -d $rootdir/eclipse ]]; then
    extrapath+=($rootdir/eclipse)
fi

# FoxitReader
if [[ -d $rootdir/FoxitReader ]]; then
    extrapath+=($rootdir/FoxitReader)
fi

sudo sed -i '/# lixq-config/d' /etc/profile

extra=""
for path in "${extrapath[@]}"; do
    extra=$extra:$path
done
sudo sed -i "\$aexport PATH=/home/lixq/toolchains/selfscripts/sbin:$rootdir/selfscripts/bin:\$PATH$extra # lixq-config" /etc/profile
extra=""
for path in "${extramanpath[@]}"; do
    extra=$extra:$path
done
sudo sed -i "\$aexport MANPATH=\$MANPATH$extra # lixq-config" /etc/profile
extra=""
for path in "${extrainfopath[@]}"; do
    extra=$extra:$path
done
sudo sed -i "\$aexport INFOPATH=\$INFOPATH$extra # lixq-config" /etc/profile
extra=""
for path in "${extragtagslibpath[@]}"; do
    extra=$extra:$path
done
sudo sed -i "\$aexport GTAGSLIBPATH=\$GTAGSLIBPATH$extra # lixq-config" /etc/profile
sudo sed -i "\$aexport GTAGSLABEL=pygments # lixq-config" /etc/profile
sudo sed -i "\$aexport GTK_IM_MODULE=fcitx # lixq-config" /etc/profile
sudo sed -i "\$aexport QT_IM_MODULE=fcitx # lixq-config" /etc/profile
sudo sed -i "\$aexport XMODIFIERS='@im=fcitx' # lixq-config" /etc/profile

sudo chown lixq:wheel -R $rootdir
