#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → clean${NC}: Deletes everything from $(pwd) except $APK_FILE_NAME."
    exit 0
fi

find . -type f -not -name "$APK_FILE_NAME" -exec rm -f {} +
find . -not \( -name "$APK_FILE_NAME" -o -path "$(pwd)/$APK_FILE_NAME" \) -delete
