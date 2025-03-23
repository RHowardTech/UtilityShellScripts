#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"
source "${BASE_DIR}/util_scripts/util_helpers/CheckAndNavigate.sh"
source "${BASE_DIR}/util_scripts/util_helpers/FilterAndReturnListOfFiles.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

saveAndReplaceJSONDataSet() {
# This function checks specified files for an expected data, saves those values and replaces the data section with a newly specified format.

    # Warn the user that the script requires manual adjustment.
    echo -e "${YELLOW}WARN: This script requires manual adjustment to change files to the format you desire.
              Without being sure of your changes this script has the power to make large scale adjustments to many files.
              Please ensure you have correctly applied all changes before running this script.${OFF}" | sed 's/^[ \t]*//' | cat

    # Request user input if values not stored.
    if [[ -z "${replace_data_repo_path}" || -z "${replace_data_directory_filter_path}" || -z "${replace_data_search_term}" ]]; then
        echo -e "${YELLOW}WARN: Missing definitions, please define the desired values in the '${OFF}${ORANGE}Data Replacement Declarations${OFF}${YELLOW}' of the '${OFF}${ORANGE}Declarations.sh${OFF}${YELLOW}' file${OFF}
                ${YELLOW}For this run you can enter the missing definitions manually below.${OFF}" | sed 's/^[ \t]*//' | cat
    fi
    if [ -z "${replace_data_repo_path}" ]; then
        echo -e "${PURPLE}Please enter the path to the required repository from the context of your '${OFF}${ORANGE}${main_repos_path}${OFF}${PURPLE}':${OFF}"
        read -r user_response
        echo -e "${CYAN}Release pipeline: ${OFF}${ORANGE}$user_response${OFF}"
        replace_data_repo_path="${user_response}"
    fi
    if [ -z "${replace_data_directory_filter_path}" ]; then
        echo -e "${PURPLE}Please enter the path to the required directory from the repository root:${OFF}"
        read -r user_response
        echo -e "${CYAN}Data directory filter path: ${OFF}${ORANGE}$user_response${OFF}"
        replace_data_directory_filter_path="${user_response}"
    fi
    if [ -z "${replace_data_search_term}" ]; then
        echo -e "${PURPLE}Please enter the desired search term within the filtered files:${OFF}"
        read -r user_response
        echo -e "${CYAN}Data search term: ${OFF}${ORANGE}$user_response${OFF}"
        replace_data_search_term="${user_response}"
    fi

    echo -e "\n${GREEN}Data replacing started:${OFF}"

    # Utilising the findAndReturnListOfFiles() function to return files to be used  - note these values set in declarations should be changed based on the goals of the script.
    find_output=$(findAndReturnListOfFiles "$main_repos_path" "$replace_data_repo_path" "$replace_data_directory_filter_path" "$replace_data_search_term")
    find_status=$?
    if (( find_status != 0 )); then
        echo -e "${RED}Exiting script:${OFF} ${YELLOW}No files passed to process.${OFF}\n"
        exit 1
    else
        # Mapping the file list so that they can be processed by the script.
        mapfile -t files_to_process <<< "$(echo "$find_output" | tr -d '\r')"
        echo -e "${GREEN}Files to process successfully passed to the data replacement script.${OFF}\n"
    fi

    # Confirm that the user has made changes and is ready to start the script.
    echo -e "${PURPLE}Please confirm you have made all required script changes and are ready for execution${OFF} ${BLUE}Y${OFF} ${PURPLE}:${OFF} ${BLUE}N${OFF}"
    read -r user_response
    if [[ "${user_response}" =~ ^y ]]; then
        echo -e "${CYAN}Confirmed Response:${OFF} ${ORANGE}$user_response${OFF}

                ${GREEN}Data replacing started:${OFF}" | sed 's/^[ \t]*//' | cat
    else
        echo -e "${CYAN}Confirmed Response:${OFF} ${ORANGE}Not yet ready to start replacer, script exited.${OFF}"
        exit 1
    fi

    # Navigate to the loop start location.
    checkAndNavigate "${main_repos_path}"
    checkAndNavigate "${replace_data_repo_path}"
    checkAndNavigate "${replace_data_directory_filter_path}"

    # Declarations for the following loop.
    declare -A extracted_data # Define an associative array (Bash v4+ required)
    checkpoint_directory=$(pwd)
    files_not_accessible=()
    files_skipped_missing_matches=()
    files_with_non_200_status_codes=()

    # Begin list loop.
    for file in "${files_to_process[@]}"; do

        # Begin the process and reset local variables to prevent any data from being persisted.
        echo -e "${CYAN}Processing file:
              '${OFF}${ORANGE}${file}${OFF}${CYAN}'${OFF}" | sed 's/^[ \t]*//' | cat
        local path=""
        local uid=""
        local full_name=""
        local date_of_birth=""
        local nationality=""
        local status_code=""

        local file_name=""
        file_name=$(basename "${file}")
        local file_directory=""
        file_directory=$(dirname "${file}")

        # Safety check for unknown files.
        if [ ! -f "${file}" ]; then
            echo -e "${RED}Error - file not found!${OFF}\n"
            files_not_accessible+=("${file_directory}")
            continue  # Skip this file and move to the next
        fi

        # Navigate to the file and extract required fields using jq  - note this should be changed based on the goals of the script.
        echo -e "${CYAN}Saving json values.${OFF}"
        checkAndNavigate "${file_directory}"
        path=$(jq -r '.request.path' "$file_name")
        uid=$(echo "$path" | awk -F'/' '{print $(NF-1)}')
        full_name=$(jq -r '.response.jsonBody.fullName' "$file_name")
        date_of_birth=$(jq -r '.response.jsonBody.dateOfBirth' "$file_name")
        nationality=$(jq -r '.response.jsonBody.nationality' "$file_name")
        status_code=$(jq -r '.response.status' "$file_name")

        # Check if required fields have stored values  - note this should be changed based on the goals of the script.
        if [[ "$path" == "null" || "$uid" == "null" || "$full_name" == "null" || "$date_of_birth" == "null" || "$status_code" == "null" ]]; then
            echo -e "${YELLOW}WARN: Skipping Replacement - Missing required fields in file '${OFF}${ORANGE}$file_name${OFF}${YELLOW}'${OFF}\n"
            files_skipped_missing_matches+=("${file_directory}")
            checkAndNavigate "${checkpoint_directory}"
            sleep 1 # Have found that the script was not properly reading some and saving some values, this wait timer is an imperfect fix to the issue.
            continue

        else
            # Store in an associative array (or write to a file)  - note this should be changed based on the goals of the script.
            extracted_data["$file"]="{
               \"path\": \"$path\",
               \"uid\": \"$uid\",
               \"fullName\": \"$full_name\",
               \"dateOfBirth\": \"$date_of_birth\",
               \"nationality\": \"$nationality\",
               \"status\": $status_code
            }"
            echo -e "${CYAN}Values have been saved for use in replacement.${OFF}
                    ${ORANGE}${extracted_data[$file]}${OFF}" | jq .
        fi

        # Safety check for non-200 status codes  - note this is optional and should be changed based on the goals of the script.
        if [[ ${status_code} == 200 ]]; then

            # Replacing the file content  - note this should be changed based on the goals of the script.
            echo -e "${CYAN}Replacing file content.${OFF}"
            jq --indent 4 \
            --arg path "/user/details/UID/$uid" \
            --arg fullName "$full_name" \
            --arg dateOfBirth "$date_of_birth" \
            --arg nationality "$nationality" \
            --arg uid "$uid" \
            '.request.path = $path
            | .response.jsonBody = {
               "core": {
                   "uid": $uid
                   "fullName": $fullName,
                   "dateOfBirth": $dateOfBirth,
                   "nationality": $nationality,
               }
            }' \
            "$file_name" > temp.json && mv temp.json "$file_name"

            # Error Handing check - is JSON valid after modification.
            jq '.' "$file_name" > /dev/null 2>&1 || {
                echo -e "${RED}ERROR:${OFF} ${YELLOW}Invalid JSON written to - '${OFF}${ORANGE}$file_name${OFF}${YELLOW}'${OFF}\n"
                files_with_invalid_json+=("$file_name")
            }

            echo -e "${GREEN}Change complete, the file has been re-written.${OFF}\n"

        else
           echo -e "${YELLOW}WARN: Skipping Replacement - Non 200 status code value '${OFF}${ORANGE}$file_name${OFF}${YELLOW}'${OFF}\n"
           files_with_non_200_status_codes+=("${file_directory}")
           checkAndNavigate "${checkpoint_directory}"
           sleep 1 # Have found that the script was not properly reading some and saving some values, this wait timer is an imperfect fix to the issue.
           continue
        fi

        checkAndNavigate "${checkpoint_directory}"
        sleep 1 # Have found that the script was not properly reading some and saving some values, this wait timer is an imperfect fix to the issue.
    done

    echo -e "${GREEN}Processing complete, printing additional information if stored:${OFF}\n"

    if [ ${#files_skipped_missing_matches[@]} -gt 0 ]; then
        echo -e "${RED}These files were skipped as they were missing expected matches:${OFF}"
        echo -e "${ORANGE}$(printf "%s\n" "${files_skipped_missing_matches[@]}")${OFF}"
        echo -e "${PURPLE}Recommend checking these files manually.${OFF}"
    fi
    if [ ${#files_with_non_200_status_codes[@]} -gt 0 ]; then
       echo -e "${RED}These files had status codes of non 200 values:${OFF}"
       echo -e "${ORANGE}$(printf "%s\n" "${files_with_non_200_status_codes[@]}")${OFF}"
       echo -e "${PURPLE}Recommend checking these files manually.${OFF}"
    fi
    if [ ${#files_with_invalid_json[@]} -gt 0 ]; then
        echo -e "${RED}Some files could not be processed due to invalid JSON:${OFF}"
        echo -e "${ORANGE}$(printf "%s\n" "${files_with_invalid_json[@]}")${OFF}"
        echo -e "${PURPLE}Recommend manually checking these files where data has not been replaced.${OFF}"
    fi
    if [ ${#files_not_accessible[@]} -gt 0 ]; then
        echo -e "${RED}Some files could not be processed:${OFF}"
        echo -e "${ORANGE}$(printf "%s\n" "${files_not_accessible[@]}")${OFF}"
        echo -e "${YELLOW}It is possible that some files also could not be captured.${OFF}
        ${PURPLE}Recommend manually checking these files where data has not been replaced.${OFF}" | sed 's/^[ \t]*//' | cat
    fi

}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the FindAndReplace.sh script.

method_name="$1"

# Check that a value has been passed.
if [ -z "$method_name" ]; then
    echo -e "${RED}Error:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
            ${ORANGE}saveAndReplaceJSONDataSet${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi

# Ensure that the value has been passed as a function.
if declare -F "$1" > /dev/null; then
    "$1"
else
    echo -e "${RED}Error:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
            ${ORANGE}saveAndReplaceJSONDataSet${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi
