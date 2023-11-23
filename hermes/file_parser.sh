#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}hermes → file_parser${NC}: Parses headers from HBC bundle."
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

echo "Parsing HBC bundle $path..."
hbc-file-parser $path >$path.hbc
echo -e "File saved to $path.hbc\n"
