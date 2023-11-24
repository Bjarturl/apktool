#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}hermes → decompiler${NC}: Decompiles Hermes bytecode to JavaScript pseudo code."
    exit 0
fi

path="$APK_NAME/assets/index.android.bundle"

if [ ! -f $path ]; then
    echo "The file $path does not exist, exiting..."
    exit 1
fi

if [ -z $(file $path | grep Hermes) ]; then
    echo "Hermes bytecode not detected in $path, exiting..."
    exit 1
fi

echo "Decompiling HBC bundle $path..."
mkdir -p hermes
hbc-decompiler $path hermes/$APK_NAME.js
echo -e "File saved to hermes/$APK_NAME.js\n"
