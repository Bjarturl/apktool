#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}hermes → disassemble${NC}: Disassembles Hermes bytecode to a more readable format."
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

echo "Disassembling HBC bundle $path..."
mkdir -p hermes
hbc-disassembler $path hermes/$APK_NAME.hasm
echo -e "File saved to hermes/$APK_NAME.hasm\n"
