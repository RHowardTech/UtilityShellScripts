#!/usr/bin/env bash

# Universal Declarations:
: "${SHELL_SCRIPT_BASE_DIR:="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"}" # Set base directory of the script.
main_repos_path="${HOME}/IdeaProjects" # Pathway to the directory structure that your repositories are kept in.

# Source global variables and helpers
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"
source "${SHELL_SCRIPT_BASE_DIR}/utility_scripts/helpers/GenericFuzzySelection.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# This section is the general executor for the script.
# It controls the products and methods that will be called based on user selection.

# Check if Bash is version 4+
((BASH_VERSINFO[0] < 4)) && {
  echo -e "${RED}ERROR:${OFF} ${YELLOW}Bash version must be 4.0 or higher. Please update your Bash.${OFF}"
  exit 1
}

# Opening message.
[[ "$1" != "recursiveTrigger" ]] && \
    echo -e "
            ${GREEN}Script Executor Started!${OFF}
            " | sed 's/^[ \t]*//' | cat

# First time user prompt.
FIRST_TIME_FLAG="${HOME}/.utilScriptRunner_first_run"
[[ ! -f "$FIRST_TIME_FLAG" ]] && {
    echo -e "${PURPLE}Welcome to the utilScriptRunner!${OFF}
            If this is your first time, please read ${BLUE}README.md${OFF} to ensure dependencies are set up correctly.
            This message will only appear once.
            " | sed 's/^[ \t]*//' | cat
    touch "$FIRST_TIME_FLAG"
}

# Run fuzzy selection on config catalogue.
GenericFuzzySelection "${SHELL_SCRIPT_BASE_DIR}/config/catalogue_of_scripts"

# Check required globals
if [[ -n "${SELECTED_KEY}" && -n "${FILE_NAME}" && -n "${RETURN_VALUE}" ]]; then
  echo -e "${CYAN}-----------------------------------------------------------------------------------------------------${OFF}
           ${GREEN}Executing method:${OFF} ${ORANGE}${SELECTED_KEY}${OFF}
           ${GREEN}From JSON file:${OFF} ${ORANGE}${FILE_NAME}${OFF}
           ${GREEN}Full command:${OFF} ${ORANGE}${SHELL_SCRIPT_BASE_DIR}/utility_scripts/${SELECTED_KEY} ${RETURN_VALUE}${OFF}
           " | sed 's/^[ \t]*//' | cat
else
  echo -e "${RED}ERROR:${OFF} ${YELLOW}Missing required parameters. Check that selection and extraction succeeded.${OFF}
          " | sed 's/^[ \t]*//' | cat && exit 1
fi

# Prevent accidental execution of .json files.
if [[ "${SELECTED_KEY}" == *.json ]]; then
  echo -e "${YELLOW}INFO:${OFF} Selected a JSON file, continuing fuzzy navigation.${OFF}"
  "${BASH_SOURCE[0]}"  # Rerun the ScriptExecutor for the next round.
  exit 0
fi

# Resolve full script path.
SCRIPT_PATH="${SHELL_SCRIPT_BASE_DIR}/utility_scripts/${SELECTED_KEY}"

# Ensure the script is executable.
[[ -f "$SCRIPT_PATH" && ! -x "$SCRIPT_PATH" ]] && chmod +x "$SCRIPT_PATH"

# Execute based on file type.
[[ ! -x "$SCRIPT_PATH" ]] && echo -e "${RED}ERROR:${OFF} ${YELLOW}The selected script has not been give executable powers.${OFF}" && exit 1

# Generic execution assuming execution type is coded into the script.
"$SCRIPT_PATH" "${RETURN_VALUE}"

# Attempt execution by file type.
#if [[ "$SCRIPT_PATH" == *.sh ]]; then
#  bash "$SCRIPT_PATH" "${RETURN_VALUE}" && execution_success=true
#elif [[ "$SCRIPT_PATH" == *.py ]]; then
#  python3 "$SCRIPT_PATH" "${RETURN_VALUE}" && execution_success=true
#elif [[ "$SCRIPT_PATH" == *.jar ]]; then
#  java -jar "$SCRIPT_PATH" "${RETURN_VALUE}" && execution_success=true
#else
#  echo -e "${YELLOW}WARN: Unsupported file type, attempting generic execution:"
#  "$SCRIPT_PATH" "${RETURN_VALUE}"
#fi

echo -e "${CYAN}-----------------------------------------------------------------------------------------------------${OFF}"

# Re-run the executor unless explicitly exited.
"${BASH_SOURCE[0]}" "recursiveTrigger"

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

