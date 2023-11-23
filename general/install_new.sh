#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → install_new${NC}: Installs reassembled $APK_FILE_NAME to running emulator device."
    exit 0
fi

echo "here: $APK_NAME"
adb install $APK_NAME/dist/$APK_NAME.apk
