#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir"

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/bashdb"* -rf
[[ -d "$destdir/bashdb" ]] && exit 0

rm "$destdir/bashdb"* -rf
rm "$destdir/src/bashdb"* -rf
mkdir -p "$destdir/src"
cd "$destdir/src" || exit 1
rm -f bashdb-*
if [ -f "$sh_dir/downloads/bashdb-"*.tar.bz2 ]; then
    cp "$sh_dir/downloads/bashdb-"*.tar.bz2 .
else
    if [[ $(LANG=en /bin/bash --version | head -n 1 | awk '{print $4}') =~ 5.0 ]]; then
        until wget https://jaist.dl.sourceforge.net/project/bashdb/bashdb/5.0-1.1.2/bashdb-5.0-1.1.2.tar.bz2; do
            rm -f bashdb-*
        done
    elif [[ $(LANG=en /bin/bash --version | head -n 1 | awk '{print $4}') =~ 4.4 ]]; then
        until wget http://downloads.sourceforge.net/project/bashdb/bashdb/4.4-0.92/bashdb-4.4-0.92.tar.bz2; do
            rm -f bashdb-*
        done
    elif [[ $(LANG=en /bin/bash --version | head -n 1 | awk '{print $4}') =~ 4.3 ]]; then
        until wget http://downloads.sourceforge.net/project/bashdb/bashdb/4.3-0.91/bashdb-4.3-0.91.tar.bz2; do
            rm -f bashdb-*
        done
    elif [[ $(LANG=en /bin/bash --version | head -n 1 | awk '{print $4}') =~ 4.2 ]]; then
        until wget http://downloads.sourceforge.net/project/bashdb/bashdb/4.2-0.8/bashdb-4.2-0.8.tar.bz2; do
            rm -f bashdb-*
        done
    elif [[ $(LANG=en /bin/bash --version | head -n 1 | awk '{print $4}') =~ 4.1 ]]; then
        until wget http://downloads.sourceforge.net/project/bashdb/bashdb/4.1-0.5/bashdb-4.1-0.5.tar.bz2; do
            rm -f bashdb-*
        done
    elif [[ $(LANG=en /bin/bash --version | head -n 1 | awk '{print $4}') =~ 4.0 ]]; then
        until wget http://downloads.sourceforge.net/project/bashdb/bashdb/4.0-0.4/bashdb-4.0-0.4.tar.bz2; do
            rm -f bashdb-*
        done
    else
        until wget http://downloads.sourceforge.net/project/bashdb/bashdb/3.1-0.09/bashdb-3.1-0.09.tar.gz; do
            rm -f bashdb-*
        done
    fi
fi
tar -xf bashdb-*
BASHDBD=$(cd "$destdir/src/bashdb-"*/ || exit 1; basename "$PWD")
cd "$destdir/src/$BASHDBD" || exit 1
./configure --prefix="$destdir/$BASHDBD"
make
make install
cd ~ || exit 1
if [[ -d "$destdir/$BASHDBD" ]]; then
    rm "$destdir/src/bashdb"* -rf
    cd "$destdir" || exit 1
    ln -s "$BASHDBD" bashdb
    echo_info "build bashdb success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build bashdb failed" >> "$destdir/src/install_from_src.log"
fi
