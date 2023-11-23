#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → unzip${NC}: Unzips $APK_FILE_NAME."
    exit 0
fi

echo -e "Unzipping $APK_FILE_NAME...\n"

rm -rf $APK_NAME
mkdir $APK_NAME
unzip $APK_FILE_NAME -d $APK_NAME
