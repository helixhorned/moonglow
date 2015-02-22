#!/bin/sh

export LD_LIBRARY_PATH=/usr/lib/nvidia-331:`pwd`

luajit depthfight.lua "$@"
