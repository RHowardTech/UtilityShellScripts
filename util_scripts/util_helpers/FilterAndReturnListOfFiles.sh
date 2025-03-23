#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

findAndReturnListOfFiles() {
# This function is reusable code for finding and returning a set of files based on given search parameters, for use in other functions.

    local main_repos_path="$1"
    local specific_repo_path="$2"
    local repo_internal_directory_path="$3"
    local data_filter_path="$4"

    # Validate that all parameters are passed
    if [[ -z "$main_repos_path" || -z "$specific_repo_path" || -z "$repo_internal_directory_path" || -z "$data_filter_path" ]]; then
        echo -e "${RED}Error:${OFF} ${YELLOW}Missing required parameters.${OFF}
        ${PURPLE}Please ensure all of the following values are passed in order with the findAndReturnListOfFiles() function:${OFF}
        ${ORANGE}<main_repos_path> <specific_repo_path> <repo_internal_directory_path> <data_filter_path>${OFF}" | sed 's/^[ \t]*//' | cat >&2
        return 1 # Exit early if no files are found
    fi

    # Navigate to Repo.
    checkAndNavigate "${main_repos_path}"
    echo -e "${CYAN}Navigating to specified repository: '${OFF}${ORANGE}${main_repos_path}/${specific_repo_path}${OFF}${CYAN}'${OFF}" >&2
    checkAndNavigate "${specific_repo_path}"

    # Navigate to required directory.
    echo -e "${CYAN}Navigating to specified directory: '${OFF}${ORANGE}${repo_internal_directory_path}${OFF}${CYAN}'${OFF}" >&2
    checkAndNavigate "${repo_internal_directory_path}"

    echo -e "${CYAN}Compiling list of all matched files by search term: '${OFF}${ORANGE}${data_filter_path}${OFF}${CYAN}'${OFF}
            ${YELLOW}WARN: Note this can take some time in large repositories, please be patient.${OFF}" | sed 's/^[ \t]*//' | cat >&2
    files_to_process=($(find . -type f ! -path '*/\.*' -exec grep -l "${data_filter_path}" {} \; | sort | uniq))
    # For more advanced searches you can also filter by file name and type.
    #files_to_process=($(find . -type f ! -path '*/\.*' -name "*.json" -exec grep -l "${data_filter_path}" {} \; | sort | uniq))

    # Check if any files were found.
    if (( ${#files_to_process[@]} == 0 )); then
        echo -e "${CYAN}No files found matching the search term: '${OFF}${ORANGE}${data_filter_path}${OFF}${CYAN}'${OFF}" >&2
        return 1  # Exit early if no files are found
    else
        echo -e "${GREEN}Found ${OFF}${BLUE}${#files_to_process[@]}${OFF}${GREEN} files to process.${OFF}" >&2
        sleep 3  # Sleep to allow the user time to see the number of files before the output starts printing.
    fi

    printf "%s\n" "${files_to_process[@]}"
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
