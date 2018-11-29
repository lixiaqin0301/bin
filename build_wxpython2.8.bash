#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

if [[ $UID -ne 0 ]]; then
    echo "must run as root"
    exit 1
fi
. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/wxPython"* -rf
[[ -d "$destdir/wxPython-2.8" ]] && exit 0

rm "$destdir/wxPython"* -rf
rm "$destdir/wxPython"* -rf
rm "$destdir/src/wxPython"* -rf
$dnfyum install mesa-libGLU-devel python-devel wxGTK-devel -y

cd "$destdir/src" || exit 1
if [[ -f "$destdir/downloads/wxPython-src-2.8.12.1.tar.bz2" ]]; then
    tar -xf "$destdir/downloads/wxPython-src-2.8.12.1.tar.bz2"
else
    rm -f wxPython-src-2.8.12.1.tar.bz2*
    until wget https://sourceforge.net/projects/wxpython/files/wxPython/2.8.12.1/wxPython-src-2.8.12.1.tar.bz2; do
        rm -f wxPython-src-2.8.12.1.tar.bz2*
    done
    tar -xf wxPython-src-2.8.12.1.tar.bz2
fi
mkdir "$destdir/src/wxPython-src-2.8.12.1/bld"
cd "$destdir/src/wxPython-src-2.8.12.1/bld" || exit 1
export CFLAGS="-Wno-narrowing"
export CXXFLAGS="-Wno-narrowing"
../configure --prefix="$destdir/wxPython-2.8.12.1" --enable-rpath="$destdir/wxPython-2.8.12.1/lib" --with-gtk --with-gnomeprint --with-opengl --enable-optimize --enable-debug_flag --enable-geometry --enable-graphics_ctx --enable-sound --with-sdl --enable-mediactrl --enable-display --enable-unicode
make
make -C contrib/src/gizmos
make -C contrib/src/stc
make install
make -C contrib/src/gizmos install
make -C contrib/src/stc install
cd "$destdir/src/wxPython-src-2.8.12.1/wxPython" || exit 1
export C_INCLUDE_PATH=$rootdir/wxPython-2.8.12.1/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$rootdir/wxPython-2.8.12.1/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=$rootdir/wxPython-2.8.12.1/lib:$LIBRARY_PATH
export LD_LIBRARY_PATH=$rootdir/wxPython-2.8.12.1/lib:$LD_LIBRARY_PATH
export PATH=$rootdir/wxPython-2.8.12.1/bin:$PATH
export WX_CONFIG=$destdir/wxPython-2.8.12.1/bin/wx-config
export CFLAGS="-Wformat=0 -Wno-error=format-security"
export CXXFLAGS="-Wformat=0 -Wno-error=format-security"
python2 setup.py build_ext --inplace --debug
python2 setup.py install
cd ~ || exit 1
if [[ -d "$destdir/wxPython-2.8.12.1" ]]; then
    rm "$destdir/src/wxPython"* -rf
    cd "$destdir" || exit 1
    ln -s wxPython-2.8.12.1 wxPython-2.8
    echo_info "build wxPython-2.8 success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build wxPython-2.8 failed" >> "$destdir/src/install_from_src.log"
fi
