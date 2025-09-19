#!/bin/bash

SCRIPT_FULL_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_FULL_PATH")"

docker build -t dojo-gpp -f Dockerfile.dojo-gpp .
export $PATH="$SCRIPT_DIR/scripts:$PATH"