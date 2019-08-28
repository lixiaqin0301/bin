#!/bin/bash
PS4='+{$LINENO:${FUNCNAME[0]}} '
sh_name="$(basename "${BASH_SOURCE[0]}")"
sh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1; pwd)"
export sh_full_path="$sh_dir/$sh_name"
cd "$sh_dir" || exit 1

. ./build_pub_fun.bash
[[ "$force" == "true" ]] && rm "$destdir/clang"* -rf
[[ -d "$destdir/clang" ]] && exit 0

if [[ $version -ge 20 ]]; then
    $dnfyum install -y clang "clang-*" llvm "llvm-*" compiler-rt
    echo_info "$dnfyum install clang success" >> "$destdir/src/install_from_src.log"
    exit 0
fi

./build_gcc.bash -r "$rootdir" -d "$rootdir"
./build_cmake.bash -r "$rootdir" -d "$rootdir"
./build_python2.bash -r "$rootdir" -d "$rootdir"

rm "$destdir/clang"* -rf
rm "$destdir/src/clang"* -rf
rm "$destdir/llvm"* -rf
rm "$destdir/src/llvm"* -rf

$dnfyum install swig libedit-devel -y
[[ $version -eq 5 ]] && yum install swig libedit-devel libxml2-devel ncurses-devel -y
[[ $version -ge 6 ]] && yum-builddep clang -y

# LLVM
cd "$destdir/src" || exit 1
if [[ -f "$sh_dir/downloads/llvm-8.0.1.src.tar" ]]; then
    tar -xf "$sh_dir/downloads/llvm-8.0.1.src.tar"
else
    rm -f llvm-8.0.1.src.tar.xz*
    until wget http://releases.llvm.org/8.0.1/llvm-8.0.1.src.tar.xz; do
        rm -f llvm-8.0.1.src.tar.xz*
    done
    xz -d llvm-8.0.1.src.tar.xz
    tar -xf llvm-8.0.1.src.tar
    rm llvm-8.0.1.src.tar
fi
mv llvm-8.0.1.src llvm
# Clang
cd "$destdir/src/llvm/tools" || exit 1
if [[ -f "$sh_dir/downloads/cfe-8.0.1.src.tar" ]]; then
    tar -xf "$sh_dir/downloads/cfe-8.0.1.src.tar"
else
    rm -f cfe-8.0.1.src.tar.xz*
    until wget http://releases.llvm.org/8.0.1/cfe-8.0.1.src.tar.xz; do
        rm -f cfe-8.0.1.src.tar*
    done
    xz -d cfe-8.0.1.src.tar.xz
    tar -xf cfe-8.0.1.src.tar
    rm cfe-8.0.1.src.tar
fi
mv cfe-8.0.1.src clang
if [[ "$small" != true ]]; then
    # extra Clang tools (optional)
    cd "$destdir/src/llvm/tools/clang/tools" || exit 1
    if [[ -f "$sh_dir/downloads/clang-tools-extra-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/clang-tools-extra-8.0.1.src.tar"
    else
        rm -f clang-tools-extra-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/clang-tools-extra-8.0.1.src.tar.xz; do
            rm -f clang-tools-extra-8.0.1.src.tar.xz*
        done
        xz -d clang-tools-extra-8.0.1.src.tar.xz
        tar -xf clang-tools-extra-8.0.1.src.tar
        rm clang-tools-extra-8.0.1.src.tar
    fi
    mv clang-tools-extra-8.0.1.src extra
    # Compiler-RT (optional)
    if [[ $version -ge 6 ]]; then
        cd "$destdir/src/llvm/projects" || exit 1
        if [[ -f "$sh_dir/downloads/compiler-rt-8.0.1.src.tar" ]]; then
            tar -xf "$sh_dir/downloads/compiler-rt-8.0.1.src.tar"
        else
            rm -f compiler-rt-8.0.1.src.tar.xz*
            until wget http://releases.llvm.org/8.0.1/compiler-rt-8.0.1.src.tar.xz; do
                rm -f compiler-rt-8.0.1.src.tar.xz*
            done
            xz -d compiler-rt-8.0.1.src.tar.xz
            tar -xf compiler-rt-8.0.1.src.tar
            rm compiler-rt-8.0.1.src.tar
        fi
        mv compiler-rt-8.0.1.src compiler-rt
    fi
    # libcxx: (only required to build and run Compiler-RT tests on OS X, optional otherwise) 
    cd "$destdir/src/llvm/projects" || exit 1
    if [[ -f "$sh_dir/downloads/libcxx-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/libcxx-8.0.1.src.tar"
    else
        rm -f libcxx-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/libcxx-8.0.1.src.tar.xz; do
            rm -f libcxx-8.0.1.src.tar.xz*
        done
        xz -d libcxx-8.0.1.src.tar.xz
        tar -xf libcxx-8.0.1.src.tar
        rm libcxx-8.0.1.src.tar
    fi
    mv libcxx-8.0.1.src libcxx
    # lldb
    if [[ $version -ge 6 ]]; then
        cd "$destdir/src/llvm/tools" || exit 1
        if [[ -f "$sh_dir/downloads/lldb-8.0.1.src.tar" ]]; then
            tar -xf "$sh_dir/downloads/lldb-8.0.1.src.tar"
        else
            rm -f lldb-8.0.1.src.tar.xz*
            until wget http://releases.llvm.org/8.0.1/lldb-8.0.1.src.tar.xz; do
                rm -f lldb-8.0.1.src.tar.xz*
            done
            xz -d lldb-8.0.1.src.tar.xz
            tar -xf lldb-8.0.1.src.tar
            rm lldb-8.0.1.src.tar
        fi
        mv lldb-8.0.1.src lldb
    fi
    # libcxxabi
    cd "$destdir/src/llvm/projects" || exit 1
    if [[ -f "$sh_dir/downloads/libcxxabi-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/libcxxabi-8.0.1.src.tar"
    else
        rm -f libcxxabi-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/libcxxabi-8.0.1.src.tar.xz; do
            rm -f libcxxabi-8.0.1.src.tar.xz*
        done
        xz -d libcxxabi-8.0.1.src.tar.xz
        tar -xf libcxxabi-8.0.1.src.tar
        rm libcxxabi-8.0.1.src.tar
    fi
    mv libcxxabi-8.0.1.src libcxxabi
    # libunwind
    cd "$destdir/src/llvm/projects" || exit 1
    if [[ -f "$sh_dir/downloads/libunwind-8.0.1.src.tar" ]]; then
        tar -xf "$destdir/downloads/libunwind-8.0.1.src.tar"
    else
        rm -f libunwind-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/libunwind-8.0.1.src.tar.xz; do
            rm -f libunwind-8.0.1.src.tar.xz*
        done
        xz -d libunwind-8.0.1.src.tar.xz
        tar -xf libunwind-8.0.1.src.tar
        rm libunwind-8.0.1.src.tar
    fi
    mv libunwind-8.0.1.src libunwind
    # lld
    cd "$destdir/src/llvm/tools" || exit 1
    if [[ -f "$sh_dir/downloads/lld-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/lld-8.0.1.src.tar"
    else
        rm -f lld-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/lld-8.0.1.src.tar.xz; do
            rm -f lld-8.0.1.src.tar.xz*
        done
        xz -d lld-8.0.1.src.tar.xz
        tar -xf lld-8.0.1.src.tar
        rm lld-8.0.1.src.tar
    fi
    mv lld-8.0.1.src lld
    # openmp
    cd "$destdir/src/llvm/projects" || exit 1
    if [[ -f "$sh_dir/downloads/openmp-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/openmp-8.0.1.src.tar"
    else
        rm -f openmp-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/openmp-8.0.1.src.tar.xz; do
            rm -f openmp-8.0.1.src.tar.xz*
        done
        xz -d openmp-8.0.1.src.tar.xz
        tar -xf openmp-8.0.1.src.tar
        rm openmp-8.0.1.src.tar
    fi
    mv openmp-8.0.1.src openmp
    # polly
    cd "$destdir/src/llvm/tools" || exit 1
    if [[ -f "$sh_dir/downloads/polly-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/polly-8.0.1.src.tar"
    else
        rm -f polly-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/polly-8.0.1.src.tar.xz; do
            rm -f polly-8.0.1.src.tar.xz*
        done
        xz -d polly-8.0.1.src.tar.xz
        tar -xf polly-8.0.1.src.tar
        rm polly-8.0.1.src.tar
    fi
    mv polly-8.0.1.src polly
    # test-suite
    cd "$destdir/src/llvm/projects" || exit 1
    if [[ -f "$sh_dir/downloads/test-suite-8.0.1.src.tar" ]]; then
        tar -xf "$sh_dir/downloads/test-suite-8.0.1.src.tar"
    else
        rm -f test-suite-8.0.1.src.tar.xz*
        until wget http://releases.llvm.org/8.0.1/test-suite-8.0.1.src.tar.xz; do
            rm -f test-suite-8.0.1.src.tar.xz*
        done
        xz -d test-suite-8.0.1.src.tar.xz
        tar -xf test-suite-8.0.1.src.tar
        rm test-suite-8.0.1.src.tar
    fi
    mv test-suite-8.0.1.src test-suite
fi
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
if [[ -f "$rootdir/Python2/bin/python" ]]; then
    pythonexcuable=$rootdir/Python2/bin/python
else
    pythonexcuable=$(command -v python)
fi

echo "CPP=$cpppath $cmakepath -DCMAKE_C_COMPILER=$ccpath -DCMAKE_CXX_COMPILER=$cxxpath -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX=$destdir/llvm-8.0.1 -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_LLVM_DYLIB=1 -DLLVM_OPTIMIZED_TABLEGEN=1 -DCMAKE_CXX_LINK_FLAGS=$cxxlinkflags -DPYTHON_EXECUTABLE=$pythonexcuable .." >> "$destdir/src/install_from_src.log"
CPP="$cpppath" "$cmakepath" -DCMAKE_C_COMPILER="$ccpath" -DCMAKE_CXX_COMPILER="$cxxpath" -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX="$destdir/llvm-8.0.1" -DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_BUILD_LLVM_DYLIB=1 -DLLVM_OPTIMIZED_TABLEGEN=1 -DCMAKE_CXX_LINK_FLAGS="$cxxlinkflags" -DPYTHON_EXECUTABLE="$pythonexcuable" ..
echo "make" >> "$destdir/src/install_from_src.log"
make 2>&1 | tee -a "$destdir/src/install_from_src.log"
if [[ $version -eq 7 ]]; then
    sed -i 's/lib\/python2.7/lib64\/python2.7/g' tools/lldb/scripts/cmake_install.cmake
fi
make install 2>&1 | tee -a "$destdir/src/install_from_src.log"
cd ~ || exit 1
if [[ -d "$destdir/llvm-8.0.1" ]]; then
    rm "$destdir/src/llvm"* -rf
    rm "$destdir/src/clang"* -rf
    cd "$destdir" || exit 1
    ln -s llvm-8.0.1 llvm
    ln -s llvm-8.0.1 clang
    echo_info "build clang success" >> "$destdir/src/install_from_src.log"
else
    echo_info "build clang failed" >> "$destdir/src/install_from_src.log"
fi

exit 0
