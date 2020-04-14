#!/bin/bash
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/clang"* -rf
[[ -d "$destdir/clang" ]] && exit 0

if [[ $version -ge 30 ]]; then
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_cmake.bash -r "$rootdir" -d "$rootdir"

rm "$destdir/clang"* -rf
rm "$destdir/src/clang"* -rf
rm "$destdir/llvm"* -rf
rm "$destdir/src/llvm"* -rf

yum install swig libedit-devel -y
yum-builddep clang -y

# LLVM
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/llvm-10.0.0.src.tar" ]]; then
    tar -xf "$sh_dir/downloads/llvm-10.0.0.src.tar"
else
    rm -f llvm-10.0.0.src.tar.xz*
    until wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/llvm-10.0.0.src.tar.xz; do
        rm -f llvm-10.0.0.src.tar.xz*
    done
    xz -d llvm-10.0.0.src.tar.xz
    tar -xf llvm-10.0.0.src.tar
    rm llvm-10.0.0.src.tar
fi
mv llvm-10.0.0.src llvm
# Clang
cd "$destdir/src/llvm/tools" || exit 1
if [[ -f "$sh_dir/downloads/clang-10.0.0.src.tar" ]]; then
    tar -xf "$sh_dir/downloads/clang-10.0.0.src.tar"
else
    rm -f clang-10.0.0.src.tar.xz*
    until wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/clang-10.0.0.src.tar.xz; do
        rm -f clang-10.0.0.src.tar*
    done
    xz -d clang-10.0.0.src.tar.xz
    tar -xf clang-10.0.0.src.tar
    rm clang-10.0.0.src.tar
fi
mv clang-10.0.0.src clang
cd "$destdir/src/llvm" || exit 1
mkdir "$destdir/src/llvm/build"
cd "$rootdir/src/llvm/build" || exit 1
if [[ -f "$rootdir/gcc/bin/gcc" ]]; then
    ccpath=$rootdir/gcc/bin/gcc
else
    ccpath=$(command -v gcc)
fi
if [[ -f "$rootdir/gcc/bin/g++" ]]; then
    cxxpath=$rootdir/gcc/bin/g++
else
    cxxpath=$(command -v g++)
fi
if [[ -f "$rootdir/gcc/bin/cpp" ]]; then
    cpppath=$rootdir/gcc/bin/cpp
else
    cpppath=$(command -v cpp)
fi
if [[ -f "$rootdir/cmake/bin/cmake" ]]; then
    cmakepath=$rootdir/cmake/bin/cmake
else
    cmakepath=$(command -v cmake)
fi
if [[ -d "$rootdir/gcc/lib64" ]]; then
    cxxlinkflags="-Wl,-rpath,$rootdir/gcc/lib64 -L$rootdir/gcc/lib64"
else
    cxxlinkflags=""
fi

echo "CPP=$cpppath $cmakepath -DCMAKE_C_COMPILER=$ccpath -DCMAKE_CXX_COMPILER=$cxxpath -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=$destdir/llvm-10.0.0 -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_LLVM_DYLIB=1 -DLLVM_OPTIMIZED_TABLEGEN=1 -DCMAKE_CXX_LINK_FLAGS=$cxxlinkflags .." >> "$destdir/src/install_from_src.log"
CPP="$cpppath" "$cmakepath" -DCMAKE_C_COMPILER="$ccpath" -DCMAKE_CXX_COMPILER="$cxxpath" -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX="$destdir/llvm-10.0.0" -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_LLVM_DYLIB=1 -DLLVM_OPTIMIZED_TABLEGEN=1 -DCMAKE_CXX_LINK_FLAGS="$cxxlinkflags" ..
echo "make" >> "$destdir/src/install_from_src.log"
make 2>&1 | tee -a "$destdir/src/install_from_src.log"
sed -i 's,lib/python2.7,lib64/python2.7,g' tools/lldb/scripts/cmake_install.cmake
make install 2>&1 | tee -a "$destdir/src/install_from_src.log"
cd ~ || exit 1
if [[ -d "$destdir/llvm-10.0.0" ]]; then
    rm "$destdir/src/llvm"* -rf
    rm "$destdir/src/clang"* -rf
    cd "$destdir" || exit 1
    ln -s llvm-10.0.0 llvm
    ln -s llvm-10.0.0 clang
    echo_info "build clang success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build clang failed" >> "$destdir/src/install_from_src.log"
fi
