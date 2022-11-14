# rm -rf build-gccrs

TARGET=sh-kos-elf

PREFIX=/opt/toolchains/gccrs

PATH="$PREFIX/bin:$PATH"

mkdir -p $PREFIX

#####################################################
# Binutils
#####################################################
mkdir -p build-binutils && \
cd build-binutils && \
../binutils/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot \
    --disable-nls \
    --disable-werror \
    && \
make -j30 && \
make -j30 install && \
cd ../

    # --with-multilib-list=m4-single-only \
    # --with-endian=little \
    # --with-cpu=m4-single-only \

#####################################################
# GCC Stage 1
#####################################################
mkdir -p build-gccrs-stage1 && \
cd build-gccrs-stage1 && \
../gccrs/configure \
    --prefix=$PREFIX \
    --target=$TARGET \
    --with-newlib \
    --disable-libgloss \
    --disable-bootstrap \
    --without-headers \
    --disable-libssp \
    --disable-tls \
    --enable-languages=c \
    --disable-gcov \
    && \
make -j30 all-gcc && \
make -j30 all-target-libgcc && \
make -j30 install-gcc && \
make -j30 install-target-libgcc && \
cd ../
# cp $PREFIX/bin/$TARGET-gcc $PREFIX/bin/$TARGET-cc && \


#####################################################
# Newlib
#####################################################
mkdir -p build-newlib && \
cd build-newlib && \
../newlib/configure \
    --prefix=$PREFIX \
    --target=$TARGET \
    --enable-newlib-multithread \
    && \
make -j30 all-target-newlib && \
make -j30 all-target-libgloss && \
make install-target-newlib && \
make install-target-libgloss && \
cd ../

#####################################################
# GCC Stage 2
#####################################################
mkdir -p build-gccrs-stage2 && \
cd build-gccrs-stage2 && \
../gccrs/configure \
    --prefix=$PREFIX \
    --target=$TARGET \
    --with-newlib \
    --disable-bootstrap \
    --disable-tls \
    --enable-threads=kos \
    --enable-languages=c,c++,rust \
    --disable-gcov \
    && \
make -j30 all-gcc && \
make -j30 all-target-libgcc && \
make -j30 install-gcc && \
make -j30 install-target-libgcc && \
cd ../