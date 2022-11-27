#!/bin/bash

cd kallistios

source environ.sh

ROOT_DIR=$(pwd)
EXAMPLE_DIR=$ROOT_DIR/examples/dreamcast

function build_example() {
    BUILD_DIR=$EXAMPLE_DIR/$1
    cd $BUILD_DIR && make clean && make && return 0

    return 1
}

# kos-cc -v && \
# # build kos
# make clean && make && \
# build_example hello && \
# build_example 2ndmix && \
# build_example basic/stackprotector && \
# build_example basic/threading/general && \
# build_example basic/threading/once && \
# build_example basic/threading/recursive_lock && \
# build_example basic/threading/rwsem && \
# build_example basic/threading/tls && \
# build_example video/bfont && \
# build_example video/minifont && \
# build_example video/palmenu && \
# # build_example pvr/bumpmap && \
# build_example pvr/cheap_shadow && \
# build_example pvr/pvrmark && \
build_example rust && \
echo "Finished Building KOS+Examples"

# cd $EXAMPLE_DIR/hello && \
# make clean && make && \
# cd $EXAMPLE_DIR/2ndmix && \
# make clean && make && \
# cd $EXAMPLE_DIR/video/bfont && \
# make clean && make && \
# cd $EXAMPLE_DIR/video/minifont && \
# make clean && make && \
# cd $EXAMPLE_DIR/video/palmenu && \
# make clean && make && \
# cd $EXAMPLE_DIR/pvr/bumpmap && \
# make clean && make && \

