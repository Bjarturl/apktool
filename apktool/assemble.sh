#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}apktool → assemble${NC}: Assembles the previously decompiled $APK_FILE_NAME."
    exit 0
fi
apktool b $APK_NAME
