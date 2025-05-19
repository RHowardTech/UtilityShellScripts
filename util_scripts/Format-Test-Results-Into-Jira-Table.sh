#!/usr/bin/env bash
SHELL_SCRIPT_BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"
source "${SHELL_SCRIPT_BASE_DIR}/utility_scripts/helpers/ProcessSerenityReport.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

createJiraFormattedTableFromTestInput() {
# This function will take user input and return that input in a plain text format compatible with Jira to form tabled information

    # Request information from the user for the report.
    # Pipeline 1
    echo -e "${PURPLE}Please enter the name of the pipeline for your report:${OFF}"
    read -r user_response
    echo -e "${CYAN}Release pipeline:${OFF} ${ORANGE}$user_response${OFF}"
    release_pipeline_1="${user_response}"

    # Release No. 1
    echo -e "${PURPLE}Please enter the release / build number for your report:${OFF}"
    read -r user_response
    echo -e "${CYAN}Release number:${OFF} ${ORANGE}$user_response${OFF}"
    release_number_1="${user_response}"

    user_flag=0
    countTool=0
    # Additional Pipeline?
    while (( user_flag == 0 )); do
        echo -e "${PURPLE}Do you want to add details of another pipeline to your report? ${OFF}${BLUE}Y${OFF}${PURPLE} : ${OFF}${BLUE}N${OFF}"
        read -r user_response
        user_response=$(echo "$user_response" | tr '[:upper:]' '[:lower:]')
        if [[ "$user_response" =~ ^y ]]; then
            echo -e "${CYAN}You selected Yes.${OFF}"
            user_flag=1
            countTool=1
        elif [[ "$user_response" =~ ^n ]]; then
            echo -e "${CYAN}You selected No.${OFF}"
            user_flag=1
        else
            echo -e "${RED}ERROR:${OFF}${YELLOW} Invalid input, please enter Y or N.${OFF}"
        fi
    done
    user_flag=0

    # If multi pipeline release:
    if (( countTool == 1 )); then

        # Pipeline 2
        echo -e "${PURPLE}Please enter the name of the pipeline for your report:${OFF}"
        read -r user_response
        echo -e "${CYAN}Release pipeline 2: ${ORANGE}$user_response${OFF}"
        release_pipeline_2="${user_response}"

        # Release No. 2
        echo -e "${PURPLE}Please enter the release / build number for your report:${OFF}"
        read -r user_response
        echo -e "${CYAN}Release number 2:${OFF} ${ORANGE}$user_response${OFF}"
        release_number_2="${user_response}"
    fi

    # Namespace
    echo -e "${PURPLE}Please enter the namespace that your test reports were generated from:${OFF}"
    read -r user_response
    echo -e "${CYAN}Environment/Namespace:${OFF} ${ORANGE}$user_response${OFF}"
    namespace="${user_response}"
    user_response=""

    # Prompt user for input (dash separated cells within a row and comma or newline separated for new rows).
    echo -e "
    ${CYAN}-----------------------------------------------------------------------------------------------------${OFF}
    ${GREEN}Initial information gathered, moving to request main report details${OFF}

    ${PURPLE}Enter servicesTags, URLs and build numbers separated by a hyphen; (new lines are either either comma or newline separated).
    When finished writing your report simply press the return key twice or use Ctrl + D on a newline.${OFF}

    ${PURPLE}Example format:
    Test Build Number - Report URL - Report Name(optional)${OFF}
    ${BLUE}12345 - https://example/link/to/report.com - Report Name
    23456 - https://example/link/to/report.com - Report 2 Name
    34567 - https://example/link/to/report.com${OFF}" | sed 's/^[ \t]*//' | cat

    entrySegments=""

    # Read input until EOF (2 empty new lines or Ctrl+D is executed on an empty line).
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Break loop if the input is an empty line (this allows users to press Enter to finish input).
        [[ -z "$line" ]] && break
        entrySegments+="$line"$'\n'
    done

    echo -e "${CYAN}Processing input.${OFF} \n"

    # Prepare JIRA table header.
    if (( countTool == 0 )); then
        jira_table="Testing data for build *${release_number_1}* _(${release_pipeline_1})_ run against *${namespace}* environment.\n"
    else
        jira_table="Testing data for build *${release_number_1}* _(${release_pipeline_1})_ & *${release_number_2}* _(${release_pipeline_2})_ run against *${namespace}* environment.\n"
    fi
    jira_table+="|| Report || Test Status || Build No. ||\n"

    # Process each website entry.
    IFS=$'\n'  # Set Internal Field Separator to newline.
    for entry in $entrySegments; do

        # Trim whitespace and split by " - ".
        entry=$(echo "${entry}" | xargs)  # Trim leading/trailing spaces.

        # Define variables for use from the user entered text.
        build_no=$(echo "$entry" | awk -F" - " '{print $1}')
        url=$(echo "$entry" | awk -F" - " '{print $2}')
        service_tag=$(echo "$entry" | awk -F" - " '{print $3}')

        # Call the report processor and save output based on which values are needed.
        output=$(processSerenityReport "${url}" "returnFailCountAndRunnerTags" 0)
        if [[ -z "${service_tag}" ]]; then
          IFS='|' read -r failure_info service_tag <<< "$output"
        else
          IFS='|' read -r failure_info _ <<< "$output"
        fi

        # In cases where a blank or no service tag has been entered, shuffle the values down the assignments and set service tag from report.
        [[ "${service_tag}" =~ ^No\ catch\ all\ tags\ detected\.$ ]] && \
        service_tag+=$(echo -e " ${YELLOW}Please re-run the generator and define the report name for this run.${OFF}")

        # Prepare report link
        report_link="[$service_tag Report|$url]"

        # Defining values in scope.
        build_message=""
        failure_message=""

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

        # Prepend the build number with a 'Build #' if it is not empty.
        [[ -n "$build_no" ]] && build_message="Build #$build_no"

        # Append to JIRA table.
        jira_table+="| $report_link | $failure_message | $build_message |\n"
    done

    # Display the JIRA table.
    echo -e "
            ${jira_table}

            ${GREEN}Jira report generated, please copy the above and paste into Jira with text mode selected in entry box.${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 0
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the Format-Test-Results-Into-Jira-Table.sh script.

method_name="$1"

# Check that a value has been passed.
[ -z "$method_name" ] && \
echo -e "${RED}ERROR:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
        ${ORANGE}createJiraFormattedTableFromTestInput${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1

# Ensure that the value has been passed as a function.
declare -F "$1" > /dev/null && "$1" || \
echo -e "${RED}ERROR:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
        ${ORANGE}createJiraFormattedTableFromTestInput${OFF}
        " | sed 's/^[ \t]*//' | cat && exit 1
