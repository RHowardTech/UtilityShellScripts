#!/usr/bin/env bash
SHELL_SCRIPT_BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"
source "${SHELL_SCRIPT_BASE_DIR}/util_scripts/helpers/ChromeLink.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# This function processes the chrome_repos list in the declarations section and creates links to brew's copy of ChromeDriver for any missing instances.

# This section contains the local executor for the Chrome-Link.sh script.

method_name="$1"

# Check that a value has been passed.
[ -z "$method_name" ] && \
echo -e "${RED}ERROR:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
        ${ORANGE}createLinkToBrewChromeDriverFromList${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

# Ensure that the value has been passed as a function.
declare -F "$1" > /dev/null && "$1" || \
echo -e "${RED}ERROR:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
        ${ORANGE}createLinkToBrewChromeDriverFromList${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1
