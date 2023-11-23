#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}frida → run${NC}: Starts Frida server on the emulator device."
    exit 0
fi

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
echo "Frida is running in the background"
