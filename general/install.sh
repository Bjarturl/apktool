#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → install${NC}: Installs $APK_FILE_NAME to running emulator device."
    exit 0
fi

echo -e "Installing $APK_FILE_NAME...\n"

echo "Installing $APK_FILE_NAME with adb..."
adb install $APK_FILE_NAME
