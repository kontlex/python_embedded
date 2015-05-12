#!/bin/sh

root_dir=$(pwd)
src_dir=${root_dir}/py_src
build_dir=${root_dir}/build
install_dir=${root_dir}/python_bin

mkdir ${build_dir}
mkdir ${install_dir}

cd ${build_dir}

#building the host components

CFLAGS=-fPIC CPPFLAGS=-fPIC  ${src_dir}/configure
CFLAGS=-fPIC CPPFLAGS=-fPIC  make python Parser/pgen
mv python hostpython
mv Parser/pgen Parser/hostpgen
make distclean

cd ${src_dir}

patch -p1 < ${src_dir}/embedded_patch/Python-2.7.2-xcompile.patch

cd ${build_dir}
PATH="${TC_TOOLCHAIN_PATH}:${PATH}"

CC=${TC_TOOLCHAIN_TRIPLET}-gcc CXX=${TC_TOOLCHAIN_TRIPLET}-g++ AR=${TC_TOOLCHAIN_TRIPLET}-ar RANLIB=${TC_TOOLCHAIN_TRIPLET}-ranlib CFLAGS=-fPIC CPPFLAGS=-fPIC ${src_dir}/configure --host=${C_TOOLCHAIN_ARCH_FULL} --build=x86_64-linux-gnu --prefix=/python

CFLAGS=-fPIC CPPFLAGS=-fPIC make HOSTPYTHON=./hostpython HOSTPGEN=./Parser/hostpgen BLDSHARED="${TC_TOOLCHAIN_TRIPLET}-gcc -shared" CROSS_COMPILE=${TC_TOOLCHAIN_TRIPLET}- CROSS_COMPILE_TARGET=yes HOSTARCH=${C_TOOLCHAIN_ARCH_FULL} BUILDARCH=x86_64-linux-gnu

make install HOSTPYTHON=./hostpython BLDSHARED="${TC_TOOLCHAIN_TRIPLET}-gcc -shared" CROSS_COMPILE=${TC_TOOLCHAIN_TRIPLET}- CROSS_COMPILE_TARGET=yes prefix=${install_dir}