#!/usr/bin/env bash
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# This script sets RETURN_VALUE based on the user's fuzzy selection of a JSON key or value within the selected JSON file.
# Called only when a JSON file is selected from GenericFuzzySelection.

# Uses values populated globally by GenericFuzzySelection.sh:
#   - FILE_NAME

SetValueFromSelectedJsonIdentifier() {
    local file_path="$1"

    # Error handling on required elements.
    [[ -z "$file_path" || -z "$FILE_NAME" ]] && echo -e "
        ${RED}ERROR:${OFF} ${YELLOW}Missing required parameters.${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

    # Error handling on passed data.
    [[ ! -f "$file_path" ]] && echo -e "
        ${RED}ERROR:${OFF} ${YELLOW}File not found: '${OFF}${ORANGE}${file_path}${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

    # Extract all top-level keys from the JSON file.
    keys=$(jq -r 'keys_unsorted[]' "$file_path" 2>/dev/null)
    [[ -z "$keys" ]] && echo -e "
        ${RED}ERROR:${OFF} ${YELLOW}No valid keys found in: ${OFF}${ORANGE}${file_path}${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

    # Adding navigation options.
    keys_with_back_and_exit=$(echo -e "Exit\nBack\n$keys")

    # Prompt the user to select a key using fzf.
    selected_key=$(echo "$keys_with_back_and_exit" | fzf \
      --height=20% --border=rounded \
      --prompt=" ^^ Select a script from the above list ^^" \
      --border-label="$(printf " ${CYAN}Select a script from '${OFF}${ORANGE}${FILE_NAME}${OFF}${CYAN}'${OFF} ")")

    # Exit if user presses ESC or selects 'Exit'.
    if [[ "$selected_key" == "Exit" || -z "$selected_key" ]]; then
        echo -e "${CYAN}User exited the key selection.${OFF}

                ${GREEN}Script Execution Complete!${OFF}
                ${GREEN}Thank you for using the script execution service.${OFF}
                " | sed 's/^[ \t]*//' | cat
        exit 0
    fi

    [[ "$selected_key" == "Back" ]] && \
        echo -e "${CYAN}Back selected. Returning to previous menu...${OFF}" && \
        GenericFuzzySelection "$(dirname "$file_path")" "Back" && \
        return 0

    # Extract the value associated with the selected key.
    selected_value=$(jq -r --arg k "$selected_key" '.[$k]' "$file_path")

    # Set globally accessible variables.
    SELECTED_KEY="$selected_key"
    RETURN_VALUE="$selected_value"
    export RETURN_VALUE

    echo -e "${CYAN}Selected Key:${OFF} ${ORANGE}${SELECTED_KEY}${OFF}
            ${CYAN}Value Set to RETURN_VALUE:${OFF} ${ORANGE}${RETURN_VALUE}${OFF}
            " | sed 's/^[ \t]*//' | cat
}

# Export the function if sourced.
return 0 2>/dev/null || SetValueFromSelectedJsonIdentifier "$@"

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

