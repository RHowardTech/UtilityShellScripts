#!/usr/bin/env bash
SHELL_SCRIPT_BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

TEMPLATE() {
    # Replace echo with execution logic here if creating a new script.
    # Remember to replace all references to TEMPLATE and rename the file when copying.
    echo -e "${RED}ERROR:${OFF} ${YELLOW}The TEMPLATE script has not yet been configured for the executor.
            For now you can check the manuallyTriggeredScripts directory for other runnable scripts.${OFF}" | sed 's/^[ \t]*//' | cat
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the TEMPLATE.sh script.

method_name="$1"

# Check that a value has been passed.
[ -z "$method_name" ] && \
echo -e "${RED}ERROR:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
        ${ORANGE}TEMPLATE${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

# Ensure that the value has been passed as a function.
declare -F "$1" > /dev/null && "$1" || \
echo -e "${RED}ERROR:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
        ${ORANGE}TEMPLATE${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1
