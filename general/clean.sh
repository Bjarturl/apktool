#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → clean${NC}: Deletes everything from $(pwd) except $APK_FILE_NAME."
    exit 0
fi

echo -e "Cleaning $(pwd)...\n"
find . -mindepth 1 -not \( -name "$APK_FILE_NAME" -o -path "$(pwd)/$APK_FILE_NAME" \) -exec rm -rf {} +
