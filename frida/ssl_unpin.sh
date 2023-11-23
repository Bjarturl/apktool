#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}frida  → ssl_unpin${NC}: Bypasses SSL pinning using Frida."
    exit 0
fi

osascript -e 'tell app "Terminal" to do script "frida --codeshare akabe1/frida-multiple-unpinning -U -f '$APK_PACKAGE_NAME'"'
