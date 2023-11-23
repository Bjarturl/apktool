#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN} → disassemble${NC}: Decompiles $APK_FILE_NAME for inspection and modification."
    exit 0
fi

echo -e "Disassembling $APK_FILE_NAME...\n"

rm -rf $APK_NAME

echo "Disassembling $APK_FILE_NAME with apktool..."
apktool d $APK_FILE_NAME
