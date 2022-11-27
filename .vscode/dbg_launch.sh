#!/bin/bash

LXDREAM_LOG=/tmp/lxdream.log

echo "Starting LXDream" > $LXDREAM_LOG

/home/coltonp/Git/lxdream-nitro/build/lxdream-nitro \
    --log=DEBUG -n -A null $@