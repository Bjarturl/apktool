#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}apkleaks → check${NC}: Checks $APK_FILE_NAME for any leaked sensitive info."
    exit 0
fi

rm -rf apkleaks.txt
echo "Checking $APK_FILE_NAME for any leaked sensitive info..."
apkleaks -f $APK_FILE_NAME | tee apkleaks.txt
echo "Done! Check apkleaks.txt for results."
