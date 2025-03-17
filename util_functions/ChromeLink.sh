#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"
source "${BASE_DIR}/util_functions/AuthoriseApplication.sh"
source "${BASE_DIR}/util_functions/CheckAndNavigate.sh"
source "${BASE_DIR}/util_functions/FilterListsForMatches.sh"
source "${BASE_DIR}/util_functions/OperatingSystemCheck.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

createLinkToBrewChromeDriverFromList() {
# This function is reusable code to processes the chrome_repos list in the declarations section and creates links to brew's
# copy of ChromeDriver for any missing instances. For use in other functions.

    # Operating system check, this script will only work for Mac.
    operatingSystemCheck "Mac"

    echo -e "${GREEN}ChromeDriver linking from defined list started:${OFF}"
    target_file="chromedriver"
    unique_directories_to_process=()
    local -a list_of_pre_processed_directories=("$@")

    # If parameter has been passed then check and remove values from list to be processed.
    if [ -z "$1" ]; then
        # Assign the chrome_repos values to be used directly.
        unique_directories_to_process=("${chrome_repos[@]}")

    else
        # Call the matcher function.
        filterListsForMatches "${chrome_repos[@]}" "${list_of_pre_processed_directories[@]}"
        # Capture the filtered values to be used.
        unique_directories_to_process=("${filtered_Array_Of_Unique_Values[@]}")
    fi

    #Navigating to the provided master directory and checking each folder for a ChromeDriver file.
    checkAndNavigate "${main_repos_path}"
    for dir in "${unique_directories_to_process[@]}"; do

        #If the navigation check is successful continue to ChromeDriver check.
        checkAndNavigate "${dir}" "${main_repos_path}/${dir}"
        if [ $? -eq 0 ]; then

            # If the ChromeDriver file is found then echo a message and move on.
            if [ -f "$target_file" ]; then
                echo -e "${RED}Linking Skipped:${OFF}${YELLOW} ChromeDriver already exists in ${OFF}${ORANGE}${dir}${OFF}"

            # If the ChromeDriver file is not found, link the file and echo a message.
            else
                linkOutput=$(ln "${brew_chromeDriver_path}" chromedriver 2>&1)

                # Error handling
                if echo "$linkOutput" | grep -q "file exists"; then
                    echo "$linkOutput"
                    echo -e "${GREEN}ChromeDriver linked in the '${OFF}${ORANGE}${dir}${OFF}${GREEN}' directory.${OFF}"
                else
                    echo -e "${YELLOW}WARN: Link attempted, file already exists in ${OFF}${ORANGE}${dir}${OFF}"
                fi
            fi
        fi

        # Returning to the navigation start position.
        checkAndNavigate ~
        checkAndNavigate "${main_repos_path}"
    done

    # Ensuring that the ChromeDriver has been authorised.
    authoriseApplication "${brew_chromeDriver_path}"

    # Close the script.
    checkAndNavigate "$return_location"
    echo -e "${GREEN}ChromeDriver Linking Complete!${OFF} \n"
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
