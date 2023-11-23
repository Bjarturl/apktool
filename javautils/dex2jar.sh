#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}javautils → dex2jar${NC}: Converts $APK_FILE_NAME to JAR (Java Archive) files."
    exit 0
fi

dex2jar -f $APK_NAME.apk -o $APK_NAME.jar
echo "Please select: File > Save All Sources in JD-GUI"
jd-gui $APK_NAME.jar
