#!/usr/bin/env bash
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"
source "${SHELL_SCRIPT_BASE_DIR}/utility_scripts/helpers/SetValueFromSelectedJsonIdentifier.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# GenericFuzzySelector: Dynamic fuzzy finder for files and JSON contents.
# Supports both directory traversal and JSON key/value selection.

# Globals (shared across scripts)
declare -g DIRECTORY_NAME=""
declare -g FILE_NAME=""
declare -g JSON_KEYS=()
declare -g JSON_VALUES=()

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# This script allows users to fuzzy-select JSON files from a directory tree.
# After selecting a file, it loads metadata such as the directory, file name,
# and top-level JSON keys/values for use across the framework.

GenericFuzzySelection() {
    local search_dir="$1"
    local back_option="$2"

    [[ -z "$search_dir" ]] && echo -e "
    ${RED}ERROR:${OFF} ${YELLOW}No directory passed to GenericFuzzySelection.${OFF}
    " | sed 's/^[ \t]*//' | cat && exit 1

    # Collect all subdirectories, (depth = 1, excluding hidden dirs).
    mapfile -t subDirs < <(find "$search_dir" -mindepth 1 -maxdepth 1 -type d ! -name ".*")

    # Collect all .json files recursively.
    mapfile -t json_paths < <(find "$search_dir" -type f -name "*.json")

    # Map display name (clean) -> full path.
    declare -A file_lookup
    local options=()

    # Add JSON file options.
    for path in "${json_paths[@]}"; do
        fileName=$(basename "$path" .json)
        options+=("$fileName")
        file_lookup["$fileName"]="$path"
    done

    # Add subdirectory options.
    for dir in "${subdirs[@]}"; do
        dirName=$(basename "$dir")
        options+=("$dirName")
        file_lookup["$dirName"]="$dir"
    done

    # Add an optional back option.
    [[ -n "$back_option" && "$search_dir" != "${SHELL_SCRIPT_BASE_DIR}/config/catalogue_of_scripts" ]] && \
    options+=("Back")
    # and a mandatory exit option.
    options+=("Exit")

    # Prompt user with fuzzy finder.
    selected_name=$(printf '%s\n' "${options[@]}" | fzf \
      --height=15% --border=rounded \
      --prompt=" ^^ Select a file from the above list ^^" \
      --border-label="$(printf " ${CYAN}Select a file from '${OFF}${ORANGE}${search_dir}${OFF}${CYAN}'${OFF} ")")

    # Exit if user presses ESC or selects 'Exit'.
    if [[ "$selected_name" == "Exit" || -z "$selected_name" ]]; then
        echo -e "${CYAN}User exited the key selection.${OFF}

                ${GREEN}Script Execution Complete!${OFF}
                ${GREEN}Thank you for using the script execution service.${OFF}
                " | sed 's/^[ \t]*//' | cat
        exit 0
    fi

    # Handle 'Back' selection.
    [[ "$selected_name" == "Back" ]] && \
        echo -e "
                ${CYAN}Back selected. Returning to previous menu...${OFF}" && \
        GenericFuzzySelection "$search_dir" "Back" && \

        return 0

    # Retrieve full path from lookup.
    selected_path="${file_lookup[$selected_name]}"

    # Global assignments.
    DIRECTORY_NAME=$(dirname "$selected_path")
    FILE_NAME=$(basename "$selected_path")
    # Export values for use in other scripts.
    export DIRECTORY_NAME FILE_NAME

    echo -e "${CYAN}Selected file:${OFF} ${ORANGE}${FILE_NAME}${OFF}"

    # Handle '.json' file selections.
    [[ "$selected_path" == *.json ]] && \
        mapfile -t JSON_KEYS < <(jq -r 'keys[]' "$selected_path") && \
        mapfile -t JSON_VALUES < <(jq -r '.[]' "$selected_path") && \
        export JSON_KEYS JSON_VALUES && \

        SetValueFromSelectedJsonIdentifier "$selected_path" && \
        return 0

    # Handle any other selection.
    GenericFuzzySelection "$selected_path" "Back"

}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
