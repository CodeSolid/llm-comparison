#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <program> [arguments...]"
    exit 1
fi

COMMAND="$@"

START_TIME=$(date +%s)

eval "$COMMAND"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo "Elapsed time: ${ELAPSED_TIME} seconds"
