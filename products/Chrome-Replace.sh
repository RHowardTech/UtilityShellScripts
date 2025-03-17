#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"
source "${BASE_DIR}/util_functions/AuthoriseApplication.sh"
source "${BASE_DIR}/util_functions/CheckAndNavigate.sh"
source "${BASE_DIR}/util_functions/OperatingSystemCheck.sh"


# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

replaceLinkToBrewChromeDriverFromList() {
# This function processes the chrome_repos list in the declarations section and replaces all linked copies of ChromeDriver.
# This function assumes that you already have a copy of ChromeDriver installed via brew and is mainly intended for reset purposes.

    # Operating system check, this script will only work for Mac.
    operatingSystemCheck "Mac"

    # First time user prompt.
    if [[ "${#chrome_repos[@]}" -eq 0 ]]; then
        echo -e "
              ${PURPLE}Welcome to the replaceChromeDriver util script, if this is your first time using this script please fill out the required variables in the ${OFF}${BLUE}Declarations.sh${OFF}${PURPLE} file.
              This script requires values in the ${OFF}'${BLUE}chrome_repos${OFF}${PURPLE}' array within the '${OFF}${BLUE}Chrome Updater Declarations${OFF}${PURPLE}' section to be populated.${OFF}
              " | sed 's/^[ \t]*//' | cat
        exit 1
    fi

    echo -e "\n${GREEN}ChromeDriver replacing started:${OFF}"
    target_file="chromedriver"

    # Navigate to the provided master directory and checking each folder (presumably a repository) for a ChromeDriver file.
    checkAndNavigate "${main_repos_path}"
    for dir in "${chrome_repos[@]}"; do

        # If the navigation check is successful continue to the ChromeDriver check.
        checkAndNavigate "${dir}" "${main_repos_path}/${dir}"
        if [[ $? -eq 0 ]]; then

            # If a copy of ChromeDriver is found inform the user remove the existing file.
            if [ -f "${target_file}" ]; then
                  echo -e "${CYAN}ChromeDriver located exists in the '${OFF}${ORANGE}${dir}${OFF}${CYAN}' directory, removing file.${OFF}"
                  rm "${target_file}"
            fi

            echo -e "${CYAN}Linking new ChromeDriver in the '${OFF}${ORANGE}${dir}${OFF}${CYAN}' directory.${OFF}"
            ln ${brew_chromeDriver_path} chromedriver
        fi

        checkAndNavigate ~
        checkAndNavigate "$main_repos_path"
    done

    # Ensuring that the ChromeDriver has been authorised.
    authoriseApplication "$brew_chromeDriver_path"

    # Close the script.
    checkAndNavigate "$return_location"
    echo -e "${GREEN}ChromeDriver Replacement Complete!${OFF} \n"
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the ChromeDriverUpdates.sh script.

method_name="$1"

# Check that a value has been passed.
if [ -z "$method_name" ]; then
    echo -e "${RED}Error:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
            ${ORANGE}replaceLinkToBrewChromeDriverFromList${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi

# Ensure that the value has been passed as a function.
if declare -F "$1" > /dev/null; then
    "$1"
else
    echo -e "${RED}Error:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
            ${ORANGE}replaceLinkToBrewChromeDriverFromList${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi
