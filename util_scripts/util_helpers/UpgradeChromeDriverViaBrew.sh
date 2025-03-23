#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

upgradeChromeDriverViaBrew() {
# This function is reusable code for updating ChromeDriver via Homebrew. For use in other functions.

    # Print starting message.
    echo -e "${GREEN}Beginning Brew Upgrade:${OFF}"

    # Execute upgrade command and capture output.
    upgrade_output=$(brew upgrade chromedriver 2>&1)
    upgrade_status=$?

    # Check if chromeDriver is already up to date and cancel the script if so.
    if [[ "${upgrade_output}" =~ "Warning: Not upgrading chromedriver" ]]; then
        echo -e "${YELLOW}WARN: Chromedriver is already updated, script will continue.${OFF}"
        return 0

    # Error handling.
    elif [ ${upgrade_status} -ne 0 ]; then
        echo -e "${RED}ChromeDriver update failed!${OFF}
                ${upgrade_output}
                " | sed 's/^[ \t]*//' | cat
        exit 1
    fi

    # Capturing the brew_chromeDriver_path for later use. The command sed (stream edit) uses the regular expression below.
    if [[ -z ${brew_chromeDriver_path} ]]; then
        brew_chromeDriver_path=$(echo "$upgrade_output" | sed -n "s/.*Linking Binary 'chromedriver' to '\([^']*\).*/\1/p'")
        echo -e "${PURPLE}Your chromeDriver path is '${OFF}${BLUE}${brew_chromeDriver_path}${OFF}${PURPLE}' please save this in the '${OFF}${BLUE}Declarations.sh${OFF}${PURPLE}' file for future use.${OFF}"
    fi
        # Pattern sections - modifier/ input & capture groups / output and capture groups / modifier.
        # Simple example - s/.*text.*/output/p
        # s/ - substitute, tells sed to search for a pattern and replace it with something else.
        # .* - matches any value at the point in the formula.
        # \([^']*\) - Captures everything inside single quotes after the previously defined text.
        # \1 - uses the first capture group, defined with the above section.
        # /p - print, tells the script to print the modified output, required as -n automatically suppresses printing so as to control the exact output.

    # Complete the process.
    echo -e "${GREEN}ChromeDriver upgrade successful.${OFF} \n"
    return 0
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
