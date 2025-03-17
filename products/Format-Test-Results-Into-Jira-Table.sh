#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

createJiraFormattedTableFromTestInput() {
# This function will take user input and return that input in a plain text format compatible with Jira to form tabled information

    # Request information from the user for the report.
    # Pipeline 1
    echo -e "${PURPLE}Please enter the name of the pipeline for your report:${OFF}"
    read -r user_response
    echo -e "${CYAN}Release pipeline: ${OFF}${ORANGE}$user_response${OFF}"
    release_pipeline_1="${user_response}"

    # Release No. 1
    echo -e "${PURPLE}Please enter the release / build number for your report:${OFF}"
    read -r user_response
    echo -e "${CYAN}Release number: ${OFF}${ORANGE}$user_response${OFF}"
    release_number_1="${user_response}"

    # Additional Pipeline?
    while [[ ${user_flag} == 0 ]]; do
        echo -e "${PURPLE}Do you want to add details of another pipeline to your report? ${OFF}${BLUE}Y${OFF}${PURPLE}:${OFF}${BLUE}N${OFF}"
        read -r user_response
        user_response=$(echo "$user_response" | tr '[:upper:]' '[:lower:]')
        if [[ "$user_response" =~ ^y ]]; then
            echo -e "${CYAN}You selected Yes.${OFF}"
            user_flag=1
            ((countTool+=1))
        elif [[ "$user_response" =~ ^n ]]; then
            echo -e "${CYAN}You selected No.${OFF}"
            user_flag=1
        else
            echo -e "${RED}Error:${OFF}${YELLOW} Invalid input, please enter Y or N.${OFF}"
        fi
    done
    user_flag=0

    # If multi pipeline release:
    if [[ ${countTool} == 1 ]]; then

        # Pipeline 2
        echo -e "${PURPLE}Please enter the name of the pipeline for your report:${OFF}"
        read -r user_response
        echo -e "${CYAN}Release pipeline 2: ${ORANGE}$user_response${OFF}"
        release_pipeline_2="${user_response}"

        # Release No. 2
        echo -e "${PURPLE}Please enter the release / build number for your report:${OFF}"
        read -r user_response
        echo -e "${CYAN}Release number 2: ${OFF}${ORANGE}$user_response${OFF}"
        release_number_2="${user_response}"
    fi

    # Namespace
    echo -e "${PURPLE}Please enter the namespace that your test reports were generated from:${OFF}"
    read -r user_response
    echo -e "${CYAN}Environment/Namespace: ${OFF}${ORANGE}$user_response${OFF}"
    namespace="${user_response}"
    user_response=""

    # Prompt user for input (dash separated cells within a row and comma or newline separated for new rows).
    echo -e "
    ${CYAN}-----------------------------------------------------------------------------------------------------${OFF}
    ${GREEN}Initial information gathered, moving to request main report details${OFF}

    ${PURPLE}Enter servicesTags, URLs, failure numbers and build numbers (either comma or newline separated).
    When finished writing your report simply press the return key twice or use Ctrl + D on a newline.${OFF}

    ${PURPLE}Example format:
    Report Name - Report URL - Number of test failures - Test Build Number${OFF}
    ${BLUE}Report Name - https://example/link/to/report.com - 5 - 12345
    Report 2 Name - https://example/link/to/report.com - - 23456
    Report 3 Name - https://example/link/to/report.com${OFF}" | sed 's/^[ \t]*//' | cat

    entrySegments=""

    # Read input until EOF (2 empty new lines or Ctrl+D is executed on an empty line).
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Break loop if the input is an empty line (this allows users to press Enter to finish input).
        [[ -z "$line" ]] && break
        entrySegments+="$line"$'\n'
    done

    # Prepare JIRA table header.
    if [[ ${countTool} == "single" ]]; then
        jira_table="Testing data for build *${release_number_1}* _(${release_pipeline_1})_ run against *${namespace}* environment.\n"
    else
        jira_table="Testing data for build *${release_number_1}* _(${release_pipeline_1})_ & *${release_number_2}* _(${release_pipeline_2})_ run against *${namespace}* environment.\n"
    fi
    jira_table+="|| Report || Test Status || Build No. ||\n"

    # Process each website entry.
    IFS=$'\n'  # Set Internal Field Separator to newline.
    for entry in $entrySegments; do

        # Defining the values and clearing them from any previous loops.
        service_tag=""
        url=""
        failure_info=""
        build_no=""
        build_message=""
        failure_message=""
        report_link=""

        # Trim whitespace and split by " - ".
        entry=$(echo "${entry}" | xargs)  # Trim leading/trailing spaces.

        service_tag=$(echo "$entry" | awk -F" - " '{print $1}')
        url=$(echo "$entry" | awk -F" - " '{print $2}')
        failure_info=$(echo "$entry" | awk -F" - " '{print $3}')
        build_no=$(echo "$entry" | awk -F" - " '{print $4}')

        if [[ "${failure_info:0:1}" == "-" ]]; then
            build_no="${failure_info:1}"
            failure_info=""
        fi

        # Prepare report link
        report_link="[$service_tag Report|$url]"

        # Prepare the failure message and status.
        if [[ -n "$failure_info" && ! "$failure_info" =~ [Pp]assed|[Pp]ass && "$failure_info" != 0 ]]; then
            # If failure info exists and it is not a "passed" case.
            failure_message="${failure_info} Failures ❌"

        else
            # For no input or anything that matches "passed", "Pass", or similar.
            failure_message="Passed (/)"
        fi

        # Clean up the build_no in case it contains 'failed -'.
        build_no=$(echo "${build_no}" | sed 's/[^0-9]*//g') # Keep only the digits, remove everything else.

        # Only prepend '#' if the build number is not empty.
        if [[ -n "$build_no" ]]; then
            build_message="Build #$build_no"
        fi

        # Append to JIRA table.
        jira_table+="| $report_link | $failure_message | $build_message |\n"
    done

    # Display the JIRA table.
    echo -e "
            ${jira_table}

            ${GREEN}Jira report generated, please copy the above and paste into Jira with text mode selected in entry box.${OFF}
            " | sed 's/^[ \t]*//' | cat
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the GenerateReports.sh script.

method_name="$1"

# Check that a value has been passed.
if [ -z "$method_name" ]; then
    echo -e "${RED}Error:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
            ${ORANGE}createJiraFormattedTableFromTestInput${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi

# Ensure that the value has been passed as a function.
if declare -F "$1" > /dev/null; then
    "$1"
else
    echo -e "${RED}Error:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
            ${ORANGE}createJiraFormattedTableFromTestInput${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi
