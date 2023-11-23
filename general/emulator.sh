#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}general → emulator${NC}: Launches Android Studio emulator."
    exit 0
fi

emulator="Pixel_6_Pro_API_33"
echo -e "Launching $emulator...\n"
osascript -e 'tell app "Terminal" to do script "'$HOME'/Library/Android/sdk/emulator/emulator -avd '$emulator'"'
echo -e "Emulator is now running.\n"
