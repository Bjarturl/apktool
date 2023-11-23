#!/bin/bash

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "${GREEN}apksigner → sign${NC}: Generates a keystore and signs $APK_FILE_NAME with it."
    exit 0
fi

# Generate the keystore
keytool -genkey -v -keystore $APK_NAME.keystore -alias $APK_NAME -keyalg RSA -keysize 2048 -validity 10000 -storepass 123123 -keypass 123123 -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"

# Sign the APK
apksigner sign --ks $APK_NAME.keystore --ks-key-alias $APK_NAME --ks-pass pass:123123 --key-pass pass:123123 $APK_NAME/dist/$APK_NAME.apk
