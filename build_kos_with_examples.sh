#!/bin/bash

cd kallistios

source environ.sh

kos-cc -v && \

make clean && make && \
cd examples/dreamcast/hello/ && \
make clean && make
