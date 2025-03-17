#!/opt/homebrew/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

filterListsForMatches() {
# This function is reusable code for filtering two lists to find the unique values from list 1. For use in other functions.

    # Capture local parameters & define return array.
    local -a array1=("${!1}")
    local -a array2=("${!2}")
    filtered_Array_Of_Unique_Values=()

    # Error handling for missing parameters.
    if [ ${#array1[@]} -eq 0 ] || [ ${#array2[@]} -eq 0 ]; then
        echo -e "${RED}Error!${OFF}${YELLOW} FilterListForMatched - missing parameter values${OFF}"
        exit 1
    fi

    # If parameter has been passed then check and remove values from list to be processed.
    echo -e "${CYAN}Filtering values from 2 passed arrays.${OFF}"
    # Loop through the values passed by array1?
    for val in "${array1[@]}"; do
        match_found=false

        # Loop through the values passed in the pre-processed list and search for matches.
        for val2 in "${array2[@]}"; do
            if [[ "$val" == "$val2" ]]; then
                match_found=true
                break
            fi
        done

        # If no match is found, add to filtered array.
        if [ "$match_found" == false ]; then
            filtered_Array_Of_Unique_Values+=("$val")
        fi
    done

    echo -e "${CYAN}List of unique values passed back for use:${OFF}"
    for val in "${filtered_Array_Of_Unique_Values[@]}"; do
        echo -e "${ORANGE}${val}${OFF}"
    done
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
