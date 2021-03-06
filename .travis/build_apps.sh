#!/bin/bash

if [[ $# -ne 1 ]]; then
    exit 1
fi

BASE_DIR=$(readlink -f $1)

FAILS=()
for dir in $BASE_DIR/*; do
    cd $dir

    if [[ ! -f "./Makefile" ]]; then
        continue
    fi
    EXAMPLE_NAME=$(basename $dir)
    echo "*** Building app $EXAMPLE_NAME ***"

    make -j5 2>&1 1>build.log
    if [[ $? -ne 0 ]]; then
        echo "Build of $EXAMPLE_NAME failed"
        FAILS+=($EXAMPLE_NAME)
        tail -n 100 build.log
        continue
    fi

    ls *.hex 1>/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "No output hex file found for $EXAMPLE_NAME"
        FAILS+=($EXAMPLE_NAME)
    fi
    echo "$EXAMPLE_NAME built properly"
done

if [[ ${#FAILS[@]} > 0 ]]; then
    echo "Apps that failed to build: ${FAILS[@]}"
    exit 1
fi
