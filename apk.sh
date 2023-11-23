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
    if [ -z "$ANDROID_HOME" ]; then
        echo -e "${RED}ANDROID_HOME is not set. Please set it to your Android SDK directory.${NC}"
        exit 1
    fi

    if [ -z "$(ls | grep .apk)" ]; then
        echo -e "${YELLOW}No apk file found in current directory${NC}"
        exit 1
    fi

    for apk in *.apk; do
        if [[ $apk == *".apk"* ]]; then
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

    if [[ -z $apk_file_name ]]; then
        echo -e "${YELLOW}No apk file found${NC}"
        exit 1
    fi

    if [[ -z $apk_package_name ]]; then
        echo -e "${YELLOW}No package name found${NC}"
        exit 1
    fi

    echo -e "${GREEN}---------------------------------------------------------------------"
    echo -e "Current directory: ${CYAN}$(pwd){NC}"
    echo -e "APK name: ${CYAN}$apk_name${NC}"
    echo -e "APK file name: ${CYAN}$apk_file_name${NC}"
    echo -e "Package name: ${CYAN}$apk_package_name${NC}"
    echo -e "${GREEN}---------------------------------------------------------------------${NC}"

    export APK_NAME="$apk_name"
    export APK_FILE_NAME="$apk_file_name"
    export APK_PACKAGE_NAME="$apk_package_name"
}

generate_menu() {
    local counter=1
    echo -e "${GREEN}Available commands:${NC}"
    for dir in $ANDROID_SCRIPTS_HOME/*; do
        if [ -d "$dir" ]; then
            local dir_name=$(basename "$dir")
            echo -e "${BLUE}$counter. $dir_name${NC}"
            local sub_counter='a'
            for script in "$dir"/*.sh; do
                if [ -f "$script" ]; then
                    local script_name=$(basename "$script" .sh)
                    echo -e "   ${YELLOW}${counter}${sub_counter}${NC} ${PURPLE}$script_name${NC}"
                    sub_counter=$(echo "$sub_counter" | tr "0-9a-z" "1-9a-z_")
                fi
            done
            counter=$((counter + 1))
        fi
    done
    echo -e "---------------------------------------------------------------------\n"
}

handle_input() {
    local choice="$1"
    local dir_index=$(echo "$choice" | grep -o -E '^[0-9]+')
    local script_index=$(echo "$choice" | grep -o -E '[a-z]+$')

    if [ -z "$dir_index" ] || [ -z "$script_index" ]; then
        echo "Invalid command. Please try again."
        return
    fi

    local dir_counter=0
    for dir in $ANDROID_SCRIPTS_HOME/*; do
        if [ -d "$dir" ] && [ "$dir_counter" -eq "$dir_index" ]; then
            local script_counter='a'
            for script in "$dir"/*.sh; do
                if [ -f "$script" ] && [ "$script_counter" == "$script_index" ]; then
                    bash "$script"
                    return
                fi
                script_counter=$(echo "$script_counter" | tr "0-9a-z" "1-9a-z_")
            done
        fi
        dir_counter=$((dir_counter + 1))
    done

    echo "Unknown command. Type 'help' followed by a command for more information."
}

show_help_for() {
    local choice="$1"
    local dir_index=$(echo "$choice" | grep -o -E '^[0-9]+')
    local script_index=$(echo "$choice" | grep -o -E '[a-z]+$')

    if [ -z "$dir_index" ] || [ -z "$script_index" ]; then
        echo "Invalid command. Please try again."
        return
    fi

    local dir_counter=0
    for dir in $ANDROID_SCRIPTS_HOME/*; do
        if [ -d "$dir" ] && [ "$dir_counter" -eq "$dir_index" ]; then
            local script_counter='a'
            for script in "$dir"/*.sh; do
                if [ -f "$script" ] && [ "$script_counter" == "$script_index" ]; then
                    bash "$script" -h
                    return
                fi
                script_counter=$(echo "$script_counter" | tr "0-9a-z" "1-9a-z_")
            done
        fi
        dir_counter=$((dir_counter + 1))
    done

    echo -e "${RED}No help available for this command.${NC}"
}

main() {
    clear
    echo -e "${CYAN}Android${NC} ${RED}Scripts${NC} ${GREEN}APK${NC} ${YELLOW}Tool${NC}\n"
    init
    while true; do
        echo ""
        read -e -p "Enter your choice: " choice
        echo ""
        history -s "$choice" # Add the choice to history

        if [[ $choice == *[Qq]* ]]; then
            break
        elif [[ $choice == "help" ]]; then
            generate_menu
        elif [[ $choice == "help"* ]]; then
            command=$(echo $choice | cut -d' ' -f2-)
            show_help_for "$command"
        elif [[ $choice == "h" ]]; then
            generate_menu
        elif [[ $choice == "h "* ]]; then
            command=$(echo $choice | sed 's/h //')
            show_help_for "$command"
        else
            handle_input "$choice"
        fi
    done
}

cleanup() {
    echo -e "\n${RED}Exiting apk tool. Goodbye!${NC}\n"
}

trap cleanup EXIT
main
