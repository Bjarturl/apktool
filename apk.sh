#!/bin/bash

# ANSI color codes
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

init() {
    while [ -z "$APK_FILE_NAME" ]; do
        if [ -z "$ANDROID_HOME" ]; then
            echo -e "${RED}ANDROID_HOME is not set. Please set it to your Android SDK directory.${NC}"
            exit 1
        fi
        echo -e "${PURPLE}Scanning for APK files in the current directory...${NC}"
        echo -e "Current directory: ${CYAN}$(pwd)${NC}"
        for apk in *.apk; do
            if [[ -f $apk && $apk == *".apk"* ]]; then
                apk_file_name=$(basename $apk)
                if [ $apk_file_name ]; then
                    apk_name=$(echo $apk_file_name | cut -d'.' -f1)
                    apk_package_name=$(aapt dump badging $apk_file_name | grep package:\ name | cut -d"'" -f2)
                fi
                if [ $apk_package_name ]; then
                    break
                fi
            fi
        done

        if [ -z "$apk_file_name" ]; then
            read -p "No APK file found in the current directory. Do you want to download one from apkleaks.com? (y/n): " download_apk
            if [[ "$(echo "$download_apk" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
                read -p "Enter the name of the APK you want to download: " apk_name_to_download
                apkpure_url="https://apkpure.com/search?q=$apk_name_to_download"
                echo "Opening apkpure.com search for '$apk_name_to_download': $apkpure_url"
                # xdg-open "$apkpure_url"  # Linux
                # start "" "$apkpure_url"  # Windows (requires 'start' command)
                open "$apkpure_url" # macOS
                read -p "Press enter when you have downloaded the APK file and placed it in the current directory."
                continue
            else
                echo -e "${RED}Goodbye${NC}"
                exit 1
            fi
        fi
        echo -e "${GREEN}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}APK file found!${NC}"
        echo -e "APK name: ${CYAN}$apk_name${NC}"
        echo -e "APK file name: ${CYAN}$apk_file_name${NC}"
        echo -e "Package name: ${CYAN}$apk_package_name${NC}"
        echo -e "${GREEN}---------------------------------------------------------------------${NC}"

        export APK_NAME="$apk_name"
        export APK_FILE_NAME="$apk_file_name"
        export APK_PACKAGE_NAME="$apk_package_name"
    done
}

main() {
    clear
    echo -e "${GREEN}---------------------------------------------------------------------"
    echo -e "Welcome!"
    echo -e "This script will help you to decompile, recompile, sign and then"
    echo -e "run your APK file."
    echo -e "---------------------------------------------------------------------${NC}"
    init
    read -p "Press enter to initialize the environment..."
    $ANDROID_SCRIPTS_HOME/general/clean.sh
    $ANDROID_SCRIPTS_HOME/general/stop.sh
    $ANDROID_SCRIPTS_HOME/general/emulator.sh

    $ANDROID_SCRIPTS_HOME/general/install.sh
    $ANDROID_SCRIPTS_HOME/general/unzip.sh

    read -p "Do you want to perform a leak scan? (y/n): " leak_scan
    if [[ "$(echo "$leak_scan" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        $ANDROID_SCRIPTS_HOME/apkleaks/check.sh
    fi

    $ANDROID_SCRIPTS_HOME/frida/run.sh
    echo -e "${BLUE}Performing SSL unpinning with Frida. Feel free to explore the app with Burp Suite or other tools."
    echo -e "To look around with Burp suite set the Wifi proxy in the emulator to 10.0.2.2:<port> and install the Burp Suite certificate."
    echo -e "When you are done looking around the app and want to continue, press enter, then Q, then enter again.${NC}"
    read -p "Press enter to start SSL unpinning."
    $ANDROID_SCRIPTS_HOME/frida/ssl_unpin.sh

    read -p "Press enter when you are ready to disassemble $APK_FILE_NAME..."

    if [[ -f "$APK_NAME/assets/index.android.bundle" ]]; then
        rm -r $APK_NAME
        $ANDROID_SCRIPTS_HOME/apktool/disassemble.sh
        $ANDROID_SCRIPTS_HOME/hermes/decompiler.sh
        $ANDROID_SCRIPTS_HOME/hermes/disassemble.sh
        $ANDROID_SCRIPTS_HOME/hermes/file_parser.sh
    else
        $ANDROID_SCRIPTS_HOME/javautils/dex2jar.sh
        echo "You can now check out your decompiled Java classes."
        exit 0
    fi
    echo -e "${YELLOW}You can now inspect the smali files in the $APK_NAME/smali* directories and make changes to them."
    echo -e "You can also take a look in the hermes folder to better understand the source code.${NC}"

    read -p "Press enter to start SSL unpinning again to take a look around again."
    $ANDROID_SCRIPTS_HOME/general/stop.sh
    $ANDROID_SCRIPTS_HOME/frida/ssl_unpin.sh

    read -p "Press enter when you are ready to recompile $APK_FILE_NAME... (make sure you have made your changes to the smali files)"
    $ANDROID_SCRIPTS_HOME/apktool/assemble.sh
    $ANDROID_SCRIPTS_HOME/apksigner/sign.sh
    $ANDROID_SCRIPTS_HOME/apksigner/verify.sh
    $ANDROID_SCRIPTS_HOME/general/stop.sh
    $ANDROID_SCRIPTS_HOME/general/uninstall.sh
    $ANDROID_SCRIPTS_HOME/general/install_new.sh
    $ANDROID_SCRIPTS_HOME/frida/ssl_unpin.sh

    echo "Your configured app has now been started up in the emulator."
    echo "${GREEN}Goodbye${NC}"
}

main
