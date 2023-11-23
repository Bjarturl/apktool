#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → start${NC}: Launches $APK_NAME in the running emulator."
    exit 0
fi

echo "Launching $APK_NAME..."
adb shell am start -n $APK_PACKAGE_NAME/.MainActivity
