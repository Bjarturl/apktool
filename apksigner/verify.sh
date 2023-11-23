#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}apksigner → verify${NC}: Verifies if $APK_FILE_NAME is correctly signed."
    exit 0
fi

apksigner verify $APK_NAME/dist/$APK_NAME.apk
