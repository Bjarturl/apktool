#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → start${NC}: Force stops $APK_NAME in the running emulator."
    exit 0
fi

echo "Stopping $APK_NAME..."
adb shell am force-stop $APK_PACKAGE_NAME
