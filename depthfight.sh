#!/bin/sh

export LD_LIBRARY_PATH=/usr/lib/nvidia-340:`pwd`

luajit depthfight.lua "$@"
