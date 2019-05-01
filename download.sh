#!/bin/bash
# download.sh

set -e

BINUTILS_VERSION=binutils-2.25
GCC_VERSION=gcc-5.2.0
LINUX_KERNEL_VERSION=linux-3.16
GLIBC_VERSION=glibc-2.22
GMP_VERSION=gmp-6.1.2
MPFR_VERSION=mpfr-4.0.1
MPC_VERSION=mpc-1.1.0

wget -nc http://ftpmirror.gnu.org/binutils/${BINUTILS_VERSION}.tar.gz
wget -nc http://ftpmirror.gnu.org/gcc/${GCC_VERSION}/${GCC_VERSION}.tar.gz
wget -nc https://www.kernel.org/pub/linux/kernel/v3.x/$LINUX_KERNEL_VERSION.tar.xz
wget -nc http://ftpmirror.gnu.org/glibc/$GLIBC_VERSION.tar.xz
wget -nc ftp://ftp.gnu.org/gnu/gmp/${GMP_VERSION}.tar.xz
wget -nc https://www.mpfr.org/mpfr-current/${MPFR_VERSION}.tar.xz
wget -nc https://ftp.gnu.org/gnu/mpc/${MPC_VERSION}.tar.gz

for f in *.tar*; do
    bsdtar xfk $f
done

mv ${GMP_VERSION} ${GCC_VERSION}/gmp
mv ${MPFR_VERSION} ${GCC_VERSION}/mpfr
mv ${MPC_VERSION} ${GCC_VERSION}/mpc
