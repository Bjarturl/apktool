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
            read -p "No APK file found in the current directory. Do you want to download one from apkpure.com? (y/n): " download_apk
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

leak_check() {
    rm -rf apkleaks.txt
    echo "Checking $APK_FILE_NAME for any leaked sensitive info..."
    apkleaks -f $APK_FILE_NAME | tee apkleaks.txt
    echo "Done! Check apkleaks.txt for results."
}

sign() {
    rm $APK_NAME.keystore
    # Generate the keystore
    keytool -genkey -v -keystore $APK_NAME.keystore -alias $APK_NAME -keyalg RSA -keysize 2048 -validity 10000 -storepass 123123 -keypass 123123 -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"

    # Sign the APK
    apksigner sign --ks $APK_NAME.keystore --ks-key-alias $APK_NAME --ks-pass pass:123123 --key-pass pass:123123 $APK_NAME/dist/$APK_FILE_NAME
}

verify() {
    apksigner verify $APK_NAME/dist/$APK_FILE_NAME
}

apktool_assemble() {
    apktool b $APK_NAME
}

jadx_convert() {
    echo -e "Initializing JADX conversion process..."
    APK_NAME=kringlan
    for dir in "$APK_NAME"/smali*; do
        if [ -d "$dir" ] && [[ "$dir" != *.cache ]]; then
            mkdir -p jadx
            dir_name=$(basename "$dir")
            output_directory="jadx/$dir_name"
            mkdir -p "$output_directory"
            echo -e "Converting $APK_NAME/$dir_name directory to Java..."
            jadx -d "$output_directory" "$dir"
        fi
    done
}

java_handler() {
    sh $HOME/netsec/android/tools/dex2jar/d2j-dex2jar.sh -f $APK_FILE_NAME -o $APK_NAME.jar
    echo -e "${GREEN}Please select: File > Save All Sources in JD-GUI. Then close the program${NC}"
    java -jar $HOME/netsec/android/tools/jd-gui-1.6.6.jar $APK_NAME.jar
    unzip $APK_NAME.jar.src.zip -d $APK_NAME-java
}

hermes_file_parser() {
    path="$APK_NAME/assets/index.android.bundle"

    if [ ! -f "$path" ]; then
        echo "The file $path does not exist"
        return
    fi

    if [ -z $(file "$path" | grep Hermes) ]; then
        echo "Hermes bytecode not detected in $path"
        return
    fi

    echo "Parsing HBC bundle $path..."
    mkdir -p hermes
    hbc-file-parser $path >hermes/$APK_NAME.hbc
    echo -e "File saved to hermes/$APK_NAME.hbc\n"
}

hermes_disassembler() {
    path="$APK_NAME/assets/index.android.bundle"

    if [ ! -f "$path" ]; then
        echo "The file $path does not exist"
        return
    fi

    if [ -z $(file "$path" | grep Hermes) ]; then
        echo "Hermes bytecode not detected in $path"
        return
    fi

    echo "Disassembling HBC bundle $path..."
    mkdir -p hermes
    hbc-disassembler $path hermes/$APK_NAME.hasm
    echo -e "File saved to hermes/$APK_NAME.hasm\n"
}

hermes_decompiler() {
    path="$APK_NAME/assets/index.android.bundle"

    if [ ! -f "$path" ]; then
        echo "The file $path does not exist"
        return
    fi

    if [ -z $(file "$path" | grep Hermes) ]; then
        echo "Hermes bytecode not detected in $path"
        return
    fi

    echo "Decompiling HBC bundle $path..."
    mkdir -p hermes
    hbc-decompiler $path hermes/$APK_NAME.js
    echo -e "File saved to hermes/$APK_NAME.js\n"
}

unzip_apk() {
    echo -e "Unzipping $APK_FILE_NAME...\n"

    rm -rf $APK_NAME
    mkdir $APK_NAME
    unzip $APK_FILE_NAME -d $APK_NAME
}

uninstall() {
    echo -e "Uninstalling $APK_PACKAGE_NAME...\n"

    echo "Uninstalling $APK_PACKAGE_NAME with adb..."
    adb uninstall $APK_PACKAGE_NAME
}

stop() {

    echo "Stopping $APK_NAME..."
    adb shell am force-stop $APK_PACKAGE_NAME
}

start() {
    echo "Launching $APK_NAME..."
    adb shell am start -n $APK_PACKAGE_NAME/.MainActivity
}

install() {

    echo -e "Installing $APK_FILE_NAME...\n"

    echo "Installing $APK_FILE_NAME with adb..."
    adb install $APK_FILE_NAME
}

install_new() {
    echo "here: $APK_NAME"
    adb install $APK_NAME/dist/$APK_FILE_NAME
}

emulator() {
    emulator="Pixel_6_Pro_API_33"

    if pgrep -f "$emulator" >/dev/null; then
        echo -e "$emulator is already running.\n"
        return
    fi

    echo -e "Launching $emulator...\n"
    osascript -e 'tell app "Terminal" to do script "'$HOME'/Library/Android/sdk/emulator/emulator -avd '$emulator'"'
    sleep 8

    echo -e "Emulator is now running.\n"
}

clean() {
    echo -e "Cleaning $(pwd)...\n"
    find . -mindepth 1 -not \( -name "$APK_FILE_NAME" -o -path "$(pwd)/$APK_FILE_NAME" \) -exec rm -rf {} +
}

ssl_unpin() {
    sleep 3
    frida --codeshare akabe1/frida-multiple-unpinning -U -f $APK_PACKAGE_NAME
}

frida_run() {
    adb root
    adb shell getprop ro.product.cpu.abi
    adb push /Users/bjartur/netsec/android/tools/frida-server-16.1.7-android-x86_64 /data/local/tmp/
    adb shell "chmod 777 /data/local/tmp/frida-server-16.1.7-android-x86_64"
    clear
    old=$(adb shell ps | grep frida-server-16.1.7-android-x86_64 | awk '{print $2}' | xargs)
    if [[ $old ]]; then
        echo "Terminating running Frida process with PID $old."
        adb shell kill -9 $old
    fi

    echo "Starting Frida..."
    osascript -e 'tell app "Terminal" to do script "adb shell \"/data/local/tmp/frida-server-16.1.7-android-x86_64 &\""'
    echo "Frida is now running in another terminal."
}

create_frida_script() {
    echo "frida -U -f $APK_PACKAGE_NAME -l $(pwd)/frida_script.js" | pbcopy
    cat <<EOF >frida_script.js
Java.perform(function () {
    /*
    You can run this script with:
    frida -U -f $APK_PACKAGE_NAME -l frida_script.js
    in a new terminal with Frida running.
    Cheat sheet: https://appsec-labs.com/portal/frida-cheatsheet-for-android/
    Examples: https://github.com/iddoeldor/frida-snippets#binder-transactions
    Run this to get an overview of loaded classes:
    timeout 10s frida -U -f $APK_PACKAGE_NAME -e "Java.perform(function () { Java.enumerateLoadedClasses({ 'onMatch': function (className) { console.log(className) }, 'onComplete': function () { } }) })" >frida_class_dump.txt
    */
    var MainActivity = Java.use("$APK_PACKAGE_NAME.MainActivity");

    // This can be any method you want
    MainActivity.onBackPressed.implementation = function () {
        try {
        // Log the method call
        console.log("MainActivity.onBackPressed called");
        // Call the original onBackPressed method
        this.onBackPressed();
        // Perform any additional actions here
        } catch (err) {
            console.log("Error in MainActivity.onBackPressed");
            console.log(err);
        }
    };
});
EOF
    code frida_script.js
}

apktool_disassemble() {
    echo -e "Disassembling $APK_FILE_NAME...\n"
    rm -rf $APK_NAME
    echo "Disassembling $APK_FILE_NAME with apktool..."
    apktool d $APK_FILE_NAME
}

get_logs() {
    adb logcat | grep "$APK_PACKAGE_NAME"
}

main() {
    clear
    echo -e "${GREEN}---------------------------------------------------------------------"
    echo -e "Welcome!"
    echo -e "This script will help you to decompile, recompile, edit, sign and then"
    echo -e "run your APK file."
    echo -e "---------------------------------------------------------------------${NC}"
    init
    if [ $# -eq 1 ]; then
        # Check if the provided argument is a valid function
        if [ "$(type -t "$1")" = "function" ]; then
            echo -e "${CYAN}Running function: $1${NC}"
            $1 # Execute the provided function
            exit 0
        else
            echo -e "${RED}Invalid function name: $1${NC}"
            exit 1
        fi
    fi
    read -p "Press enter to initialize the environment..."
    clean
    stop
    emulator
    install
    unzip_apk

    read -p "Do you want to perform a leak scan? (y/n): " leak_scan
    if [[ "$(echo "$leak_scan" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        leak_check
    fi

    frida_run
    echo -e "${BLUE}Performing SSL unpinning with Frida. Feel free to explore the app with Burp Suite or other tools."
    echo -e "To look around with Burp suite set the Wifi proxy in the emulator to 10.0.2.2:<port> and install the Burp Suite certificate."
    echo -e "You might need to turn off the Wifi, with no proxy enabled, then turn it back on until you have an active connection."
    echo -e "When you have a connection then you can configure the proxy."
    echo -e "When you are done looking around the app and want to continue, press enter, then Q, then enter again.${NC}"
    read -p "Do you want to perform SSL unpinning? (y/n): " ssl_unpinning
    if [[ "$(echo "$ssl_unpinning" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        ssl_unpin
    fi

    read -p "Press enter when you are ready to disassemble $APK_FILE_NAME..."

    if [[ -f "$APK_NAME/assets/index.android.bundle" ]]; then
        echo -e "Native app detected. Running the appropriate decompilers..."
        rm -r $APK_NAME
        apktool_disassemble
        jadx_convert
        hermes_decompiler
        hermes_disassembler
        hermes_file_parser
    else
        java_handler
        echo "You can now check out your decompiled Java classes."
        read -p "Do you want to do some Frida debugging? (y/n): " frida_debugging
        if [[ "$(echo "$frida_debugging" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
            create_frida_script
            ssl_unpin
        fi
        echo "${RED}Goodbye!${NC}"
        exit 0
    fi

    echo -e "${YELLOW}You can now inspect the smali files in the $APK_NAME/smali* directories and make changes to them."
    echo -e "You can also take a look in the hermes or jadx folders to get a better understanding of the source code.${NC}"

    read -p "Do you want to do some Frida debugging? (y/n): " frida_debugging
    if [[ "$(echo "$frida_debugging" | tr '[:upper:]' '[:lower:]')" == "y" ]]; then
        create_frida_script
    fi

    read -p "Press enter to perform SSL unpinning again to take a look around again."
    stop
    ssl_unpin

    read -p "Press enter when you are ready to recompile $APK_FILE_NAME... (make sure you have made your changes to the smali files)"
    apktool_assemble
    sign
    verify
    stop
    uninstall
    install_new
    ssl_unpin

    echo "Your configured app has now been started up in the emulator."
    echo "${GREEN}Goodbye${NC}"
}

if [ "$#" -eq 1 ]; then
    main "$1"
else
    main
fi
