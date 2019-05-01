#!/bin/bash
# build.sh

set -e

PREFIX=/usr/local
PARALLEL_MAKE=-j4
CONFIGURATION_OPTIONS="--disable-multilib --disable-nls"

BINUTILS_VERSION=binutils-2.25
GCC_VERSION=gcc-5.2.0
LINUX_KERNEL_VERSION=linux-3.16
GLIBC_VERSION=glibc-2.22

build() {
    local TARGET="$1"
    local LINUX_ARCH="$2"

    # Step 1. Binutils
    mkdir -p build-binutils-$TARGET
    cd build-binutils-$TARGET
    ../$BINUTILS_VERSION/configure --prefix=$PREFIX --target=$TARGET $CONFIGURATION_OPTIONS
    make $PARALLEL_MAKE
    make install
    cd ..

    # Step 2. Linux Kernel Headers
    cd $LINUX_KERNEL_VERSION
    make ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$PREFIX/$TARGET headers_install
    cd ..

    # Step 3. C/C++ Compilers
    mkdir -p build-gcc-$TARGET
    cd build-gcc-$TARGET
    ../$GCC_VERSION/configure --prefix=$PREFIX --target=$TARGET --enable-languages=c,c++ $CONFIGURATION_OPTIONS
    make $PARALLEL_MAKE gcc_cv_libc_provides_ssp=yes all-gcc
    make install-gcc
    cd ..

    # Step 4. Standard C Library Headers and Startup Files
    mkdir -p build-glibc-$TARGET
    cd build-glibc-$TARGET
    ../$GLIBC_VERSION/configure --prefix=$PREFIX/$TARGET --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-headers=$PREFIX/$TARGET/include $CONFIGURATION_OPTIONS libc_cv_forced_unwind=yes
    make install-bootstrap-headers=yes install-headers
    make $PARALLEL_MAKE csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o $PREFIX/$TARGET/lib
    $TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $PREFIX/$TARGET/lib/libc.so
    touch $PREFIX/$TARGET/include/gnu/stubs.h
    cd ..

    # Step 5. Compiler Support Library
    cd build-gcc-$TARGET
    make $PARALLEL_MAKE all-target-libgcc
    make install-target-libgcc
    cd ..

    # Step 6. Standard C Library & the rest of Glibc
    cd build-glibc-$TARGET
    make $PARALLEL_MAKE
    make install
    cd ..

    # Step 7. Standard C++ Library & the rest of GCC
    cd build-gcc-$TARGET
    make $PARALLEL_MAKE all
    make install
    cd ..

    rm -rf build-binutils-$TARGET build-gcc-$TARGET build-glibc-$TARGET
}

build i686-linux-gnu x86
build arm-linux-gnueabi arm
build arm-linux-gnueabihf arm
build aarch64-linux-gnu arm64
build powerpc-linux-gnu powerpc
build powerpc64le-linux-gnu powerpc
build mips-linux-gnu mips
build mipsel-linux-gnu mips
build mips64el-linux-gnuabi64 mips
build alpha-linux-gnu alpha
build s390x-linux-gnu s390
build m68k-linux-gnu m68k

#build x86_64-linux-gnu x86
#build sparc-linux-gnu sparc
#build sparc64-linux-gnu sparc
#build cris-linux-gnu cris
#build sh4-linux-gnu sh

echo "Build Success!!"
