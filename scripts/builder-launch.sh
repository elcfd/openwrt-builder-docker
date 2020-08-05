#!/bin/bash

workdir=$1
shift
cd $workdir
if [ $# -gt 0 ]; then
    exec "$@"
else
    exec bash -i
fi
