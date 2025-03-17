#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"
source "${BASE_DIR}/util_functions/ChromeLink.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# This function processes the chrome_repos list in the declarations section and creates links to brew's copy of ChromeDriver for any missing instances.

# This section contains the local executor for the ChromeDriverUpdates.sh script.

method_name="$1"

# Check that a value has been passed.
if [ -z "$method_name" ]; then
    echo -e "${RED}Error:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
            ${ORANGE}createLinkToBrewChromeDriverFromList${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi

# Ensure that the value has been passed as a function.
if declare -F "$1" > /dev/null; then
    "$1"
else
    echo -e "${RED}Error:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
            ${ORANGE}createLinkToBrewChromeDriverFromList${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi
