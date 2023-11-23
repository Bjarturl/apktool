#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → uninstall${NC}: Uninstalls $APK_PACKAGE_NAME from running emulator device."
    exit 0
fi

echo -e "Uninstalling $APK_PACKAGE_NAME...\n"

echo "Uninstalling $APK_PACKAGE_NAME with adb..."
adb uninstall $APK_PACKAGE_NAME
