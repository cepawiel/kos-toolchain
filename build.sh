# rm -rf build-gccrs

TARGET=sh-kos-elf
PREFIX=/opt/toolchains/gccrs
PATH="$PREFIX/bin:$PATH"

TOOLCHAIN_DIR=$PWD

# Source Dirs
BINUTILS_SRC=$TOOLCHAIN_DIR/binutils
GCC_SRC=$TOOLCHAIN_DIR/gccrs
NEWLIB_SRC=$TOOLCHAIN_DIR/newlib_upstream
PICOLIBC_SRC=$TOOLCHAIN_DIR/picolibc

# Build Dir
BUILD_DIR=$TOOLCHAIN_DIR/build
#
BINUTILS_BUILD=$BUILD_DIR/build-binutils
GCC_STAGE1_BUILD=$BUILD_DIR/build-gcc-stage1
NEWLIB_BUILD=$BUILD_DIR/build-newlib
PICOLIBC_BUILD=$BUILD_DIR/build-picolibc
GCC_STAGE2_BUILD=$BUILD_DIR/build-gcc-stage2

# Logs Dir
BUILD_LOGS=$TOOLCHAIN_DIR/logs

# Log Files
BINUTILS_LOG=$BUILD_LOGS/binutils.log
GCC_STAGE1_LOG=$BUILD_LOGS/gcc_stage1.log
NEWLIB_LOG=$BUILD_LOGS/newlib.log
PICOLIBC_LOG=$BUILD_LOGS/picolibc.log
GCC_STAGE2_LOG=$BUILD_LOGS/gcc_stage2.log

#####################################################
# Log Helpers
#####################################################
function new_log() {
    echo "Creating new log: $1"
    echo "" > $1
}

function new_step() {
    echo $2
    echo "================================================================================" >> $1
    echo "        $2" >> $1
    echo "================================================================================" >> $1
}

function log_build() {
    LOG=$1
    shift
    echo "$@" >> $LOG
    $@ &>> $LOG 
}

#####################################################
# Binutils
#####################################################
function build_binutils() {
    new_log  $BINUTILS_LOG && \
    mkdir -p $BINUTILS_BUILD && \
    cd $BINUTILS_BUILD && \
    new_step $BINUTILS_LOG "binutils configure" && \
    log_build $BINUTILS_LOG $BINUTILS_SRC/configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --with-sysroot \
        --disable-nls \
        --disable-werror \
        && \
    new_step $BINUTILS_LOG "binutils make" && \
    log_build $BINUTILS_LOG make -j30 && \
    new_step $BINUTILS_LOG "binutils make install" && \
    log_build $BINUTILS_LOG make -j30 install && \
    new_step $BINUTILS_LOG "binutils finished" && \
    cd $TOOLCHAIN_DIR || 
        (echo "Failed to build Binutils" && exit 1)
}
    # --with-multilib-list=m4-single-only \
    # --with-endian=little \
    # --with-cpu=m4-single-only \


#####################################################
# GCC Stage 1 # --disable-bootstrap \
#####################################################
function build_gcc_stage1() {
    new_log  $GCC_STAGE1_LOG && \
    mkdir -p $GCC_STAGE1_BUILD && \
    cd $GCC_STAGE1_BUILD && \
    new_step $GCC_STAGE1_LOG "gcc stage1 configure" && \
    log_build $GCC_STAGE1_LOG $GCC_SRC/configure \
        --prefix=$PREFIX \
        --target=$TARGET \
        --with-newlib \
        --disable-libgloss \
        --without-headers \
        --disable-libssp \
        --enable-languages=c \
        --disable-gcov \
        && \
    new_step $GCC_STAGE1_LOG "gcc stage1 all-gcc" && \
    log_build $GCC_STAGE1_LOG make -j30 all-gcc && \
    new_step $GCC_STAGE1_LOG "gcc stage1 all-target-libgcc" && \
    log_build $GCC_STAGE1_LOG make -j30 all-target-libgcc && \
    new_step $GCC_STAGE1_LOG "gcc stage1 install-gcc" && \
    log_build $GCC_STAGE1_LOG make -j30 install-gcc && \
    new_step $GCC_STAGE1_LOG "gcc stage1 install-target-libgcc" && \
    log_build $GCC_STAGE1_LOG make -j30 install-target-libgcc && \
    new_step $GCC_STAGE1_LOG "gcc stage1 finished" && \
    cd $TOOLCHAIN_DIR || 
        (echo "Failed to build GCC Stage 1" && exit 2)
}

#####################################################
# Newlib
#####################################################
function build_newlib() {
    new_log  $NEWLIB_LOG && \
    mkdir -p $NEWLIB_BUILD && \
    cd $NEWLIB_BUILD && \
    new_step $NEWLIB_LOG "newlib configure" && \
    log_build $NEWLIB_LOG $NEWLIB_SRC/configure \
        --prefix=$PREFIX \
        --target=$TARGET \
        --enable-newlib-multithread \
        && \
    new_step $NEWLIB_LOG "newlib all-target-newlib" && \
    log_build $NEWLIB_LOG make -j30 all-target-newlib && \
    new_step $NEWLIB_LOG "newlib all-target-libgloss" && \
    log_build $NEWLIB_LOG make -j30 all-target-libgloss && \
    new_step $NEWLIB_LOG "newlib install-target-newlib" && \
    log_build $NEWLIB_LOG make install-target-newlib && \
    new_step $NEWLIB_LOG "newlib install-target-libgloss" && \
    log_build $NEWLIB_LOG make install-target-libgloss && \
    new_step $NEWLIB_LOG "newlib finished" && \
    cd $TOOLCHAIN_DIR || 
        (echo "Failed to build newlib" && exit 3)
}

#####################################################
# Picolibc
#####################################################
function build_picolibc() {
    new_log  $PICOLIBC_LOG && \
    mkdir -p $PICOLIBC_BUILD && \
    cd $PICOLIBC_BUILD && \
    new_step $PICOLIBC_LOG "picolibc configure" && \
    log_build $PICOLIBC_LOG $PICOLIBC_SRC/scripts/do-kos-sh-configure \
        -Dprefix=$PREFIX \
        -Dpicocrt=false \
        -Dsysroot-install=true \
        -Dpicolib=false \
        -Dtinystdio=false \
        -Dnewlib-stdio64=false \
        -Datomic-ungetc=false \
        -Dformat-default=integer \
        -Dbuildtype=debug \
        && \
    new_step $PICOLIBC_LOG "picolibc compile" && \
    log_build $PICOLIBC_LOG meson compile -v && \
    new_step $PICOLIBC_LOG "picolibc install" && \
    log_build $PICOLIBC_LOG meson install &&\
    cd $TOOLCHAIN_DIR || 
        (echo "Failed to build picolibc" && exit 3)
}

#####################################################
# GCC Stage 2
#####################################################

function build_gcc_stage2() {
# --disable-libstdc++-v3 \

    new_log  $GCC_STAGE2_LOG && \
    mkdir -p $GCC_STAGE2_BUILD && \
    cd $GCC_STAGE2_BUILD && \
    new_step $GCC_STAGE2_LOG "gcc stage2 configure" && \
    log_build $GCC_STAGE2_LOG $GCC_SRC/configure \
        --prefix=$PREFIX \
        --target=$TARGET \
        --with-newlib \
        --enable-threads=kos \
        --enable-languages=c,c++,rust \
        --disable-gcov \
        && \
    new_step $GCC_STAGE2_LOG "gcc stage2 all-gcc" && \
    log_build $GCC_STAGE2_LOG make -j30 all-gcc && \
    new_step $GCC_STAGE2_LOG "gcc stage2 all-target-libgcc" && \
    log_build $GCC_STAGE2_LOG make -j30 all-target-libgcc && \
    new_step $GCC_STAGE2_LOG "gcc stage2 install-gcc" && \
    log_build $GCC_STAGE2_LOG make -j30 install-gcc && \
    new_step $GCC_STAGE2_LOG "gcc stage2 install-target-libgcc" && \
    log_build $GCC_STAGE2_LOG make -j30 install-target-libgcc && \
    new_step $GCC_STAGE2_LOG "gcc stage2 finished" && \
    cd $TOOLCHAIN_DIR || 
        (echo "Failed to build GCC Stage2" && exit 4)
}

mkdir -p $BUILD_LOGS
mkdir -p $PREFIX

build_binutils && \
build_gcc_stage1 && \
build_picolibc && \
build_gcc_stage2 && \
echo "Toolchain Build Completed!"