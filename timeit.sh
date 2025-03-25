#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <program> [arguments...]"
    exit 1
fi

COMMAND="$@"

START_TIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')
echo "$START_TIME"

eval "$COMMAND"

END_TIME=$(perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)')
echo "$END_TIME"
ELAPSED_TIME=$((END_TIME - START_TIME))
SECONDS=$(echo "$ELAPSED_TIME" | bc)

echo "Elapsed time: ${SECONDS} ms"
