#!/usr/bin/env bash
SHELL_SCRIPT_BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"
source "${SHELL_SCRIPT_BASE_DIR}/utility_scripts/helpers/AuthoriseApplication.sh"
source "${SHELL_SCRIPT_BASE_DIR}/utility_scripts/helpers/CheckAndNavigate.sh"
source "${SHELL_SCRIPT_BASE_DIR}/utility_scripts/helpers/OperatingSystemCheck.sh"


# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

replaceLinkToBrewChromeDriverFromList() {
# This function processes the chrome_repos list in the declarations section and replaces all linked copies of ChromeDriver.
# This function assumes that you already have a copy of ChromeDriver installed via brew and is mainly intended for reset purposes.

    # Operating system check, this script will only work for Mac.
    operatingSystemCheck "macOS"

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
    exit 0
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the Chrome-Replace.sh script.

method_name="$1"

# Check that a value has been passed.
[ -z "$method_name" ] && \
echo -e "${RED}ERROR:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
        ${ORANGE}replaceLinkToBrewChromeDriverFromList${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

# Ensure that the value has been passed as a function.
declare -F "$1" > /dev/null && "$1" || \
echo -e "${RED}ERROR:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
        ${ORANGE}replaceLinkToBrewChromeDriverFromList${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1
