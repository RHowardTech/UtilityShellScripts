#!/usr/bin/env bash
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# Global declaration of the tag_map for use across all functions.
declare -A tag_map
declare -a runner_tag_names=()
declare -a failed_tags=()
max_value=0
fail_count=0
pass_count=0

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

extract_tags_with_names_numbers_and_colours_then_run_checks() {
# This function is reusable code for compiling a list of acceptable tag segments from a serenity report. For use in other functions.

    # Defines local variables.
    local html="$1"
    [[ -n $2 ]] && local DEBUG_LOGGING="$2"

    (( DEBUG_LOGGING )) && echo -e "${CYAN}Handling of report page initiated.${OFF}"

    # Defines the xpath to use all.
    xpath_query="//*/h3[contains(text(),'Tags')]/../div[1]/div/div/a/span"

    # Define the maximum test count.
    test_count_xpath_query=$(echo "$html" | xmllint --html --xpath "//*/div[contains(@class, 'test-count-title')]/text()" 2>/dev/null -)
    test_count_xpath_query_cleaned=$(echo "$test_count_xpath_query" | tr -d '\n' | tr -d '[:space:]')
    max_value=$(echo "$test_count_xpath_query_cleaned" | grep -o '^[0-9]\+')

    # Prints the html text to be processed in the background filtering to only use the sections with the given xpath.
    (( DEBUG_LOGGING )) && echo -e "${CYAN}Extracting values from returned HTML content.${OFF}"
    extracted_html=$(echo "$html" | xmllint --html --xpath "$xpath_query" 2>/dev/null -)

    (( DEBUG_LOGGING )) && echo -e "${CYAN}Filtering content into an array of elements.${OFF}"
    readarray -t span_segments < <(echo "$extracted_html" | tr -d '\n' | grep -oE '<span[^>]*>.*?</span>')

    # Read extracted spans into a loop.
    (( DEBUG_LOGGING )) && \
    echo -e "${CYAN}Beginning separation and processing loop:${OFF}
            ${YELLOW}WARN: This process can take a few minutes to complete depending on the size of the test pack, please be patient:${OFF}" | sed 's/^[ \t]*//' | cat
    for span in "${span_segments[@]}"; do

        # Extract background colour.
        (( DEBUG_LOGGING )) && echo -e "${CYAN}Extracting background colour.${OFF}"
        colour=$(echo "$span" | sed -E 's/.*background-color:#([^;]+);.*/#\1/')
        [[ -z "$colour" ]] && continue

        # Extract tag name and number.
        tag_name_and_number=$(echo "$span" | sed -E 's|.*<i class="bi bi-tag-fill"/> *([^<]+).*|\1|')
        # For an unknown reason this segment pulls with a ton of hidden characters so we need to properly clean the data before
        # separation to ensure we're segmenting the correct data.

            # Step 1: Replace *all* non-breaking spaces with real spaces.
            tag_name_and_number=$(echo "$tag_name_and_number" | sed 's/\xC2\xA0/ /g')
            # Step 2: Remove anything that's not printable or space-like.
            tag_name_and_number=$(echo "$tag_name_and_number" | tr -cd '[:alnum:][:space:]-')
            # Step 3: Trim extra space from ends.
            tag_name_and_number=$(echo "$tag_name_and_number" | xargs)

        # Extract number (last section after space).
        (( DEBUG_LOGGING )) && echo -e "${CYAN}Extracting tag test number.${OFF}"
        number_of_tests=$(echo "$tag_name_and_number" | grep -oE '[0-9]+$')
        [[ -z "$number_of_tests" ]] && continue

        # Extract tag name by removing the number.
        (( DEBUG_LOGGING )) && echo -e "${CYAN}Extracting tag name.${OFF}"
        tag_name=${tag_name_and_number%"$number_of_tests"}
        tag_name=$(echo "$tag_name" | tr -d '[:space:]')
        [[ -z "$tag_name" ]] && continue

# TODO trace back why this section of logs is interfacing with the Format-Test-Results-Into-Jira-Table script and correct.
        # Print extracted values.
#        (( INFO_LOGGING )) && \
#        echo -e "${CYAN}Background Colour:${OFF} ${ORANGE}${colour}${OFF}
#                ${CYAN}Tag Name:${OFF} ${ORANGE}${tag_name}${OFF}
#                ${CYAN}Tag Test Number:${OFF} ${ORANGE}${number_of_tests}${OFF}" | sed 's/^[ \t]*//' | cat

        # Temporarily remove case sensitivity for the next check.
        shopt -s nocasematch

        # Check the tag_map keys for matches of the excluded names.
        (( DEBUG_LOGGING )) && echo -e "${CYAN}Throwing out ignored data.${OFF}"
        if [[ ! "$tag_name" =~ ^(Dev|Feat|Autosit|Bsit|Csit|Api|Staa|Csapi|Irs|Iabs|Ui|Timeout)$ ]]; then

            # Re-add case sensitivity.
            shopt -u nocasematch

            # Check tags against the maximum number for valid runner tags.
            if [[ "$max_value" =~ ^[0-9]+$ ]] && [[ "$number_of_tests" =~ ^[0-9]+$ ]]; then
                [ "$number_of_tests" -eq "$max_value" ] && runner_tag_names+=("$tag_name")
            else
                echo -e "${RED}ERROR:${OFF} ${YELLOW}Invalid number(s)
                number=${OFF}${ORANGE}${number_of_tests}${OFF}${YELLOW}
                max_value=${OFF}${ORANGE}${max_value}${OFF}" | sed 's/^[ \t]*//' | cat && exit 0
            fi

            # Check if there is a filterCondition set.
            if [ -n "${filterCondition}" ]; then

                # If so only check colours for filtered tags.
                if [[ "${tag_name}" =~ ^$filterCondition ]]; then
                    # Check the colour and act accordingly.
                    (( DEBUG_LOGGING )) && echo -e "${CYAN}Checking colour tag data: '${OFF}${ORANGE}${colour}${OFF}${CYAN}'${OFF}"
                    if [[ "${colour}" == "#fd938e" || "$colour" == "#fe6c2d" ]]; then
                        ((fail_count++))
                        failed_tags+=("$tag_name")
                    elif [[ "${colour}" == "#b0cf73" ]]; then
                        ((pass_count++))
                    else
                        echo -e "${YELLOW}WARN: colour passed not recognised '${OFF}${ORANGE}${colour}${OFF}'.${OFF}" >&2
                    fi
                # If no match then skip
                else
                    continue
                fi
            # Otherwise continue to check colours for all tags.
            else
                # Check the colour and act accordingly.
                (( DEBUG_LOGGING )) && echo -e "${CYAN}Checking colour tag data: '${OFF}${ORANGE}${colour}${OFF}${CYAN}'${OFF}"
                if [[ "${colour}" == "#fd938e" || "$colour" == "#fe6c2d" ]]; then
                    ((fail_count++))
                    failed_tags+=("$tag_name")
                elif [[ "${colour}" == "#b0cf73" ]]; then
                    ((pass_count++))
                else
                    echo -e "${YELLOW}WARN: colour passed not recognised '${OFF}${ORANGE}${colour}${OFF}'.${OFF}" >&2
                fi
            fi

        else
            continue
        fi

        # Store in the map for later use if required.
        (( DEBUG_LOGGING )) && echo -e "${CYAN}Storing the values into the tag_map for processing.${OFF}"
        tag_map["$tag_name"]="$colour $number_of_tests"
    done
    [[ ${#runner_tag_names[@]} -eq 0 ]] && runner_tag_names+=("No catch all tags detected.")
    (( DEBUG_LOGGING )) && echo -e "${GREEN}Separation and processing loop completed.${OFF} \n"
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

split_tag_data() {
    # This function takes the tag data, splits it into colour and number, and assigns them to global variables.
    local tag_data="$1"  # Passed in tag_data (colour number).

    # Split the data into colour and number.
    colour=$(echo "$tag_data" | cut -d ' ' -f 1 | xargs)
    number=$(echo "$tag_data" | cut -d ' ' -f 2 | xargs)
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

process_tags() {
# This function will process all tags from the tag_map.

    # Initialise local values:
    declare -A processed_tag_map
    echo -e "${CYAN}Processing extracted data:${OFF}"

    # First loop to iterate over the keys in the tag_map.
    for key in "${!tag_map[@]}"; do

        # Call the generic function to split the tag data.
        #echo -e "${CYAN}Splitting tag data.${OFF}"
        split_tag_data "${tag_map[$key]}"

        # Execute any processing required on the individual tags.
        # <write new processes>

    done

    # Echo all values as a single space-separated string.
    echo -e "${GREEN}Processing completed.${OFF}
            ${CYAN}<Write new process outputs.>${OFF}" | sed 's/^[ \t]*//' | cat
}
# ——————————————————————————————————————————————————————————————————————————————————————————————————————

printTagsInFormat() {
# This function is reusable code for printing tags from an array. For use in other functions.

    local -n array_ref=$1
    local andOr=$2

    # Error handling and process for the array parameter.
    [[ -z "$1" || -z "${array_ref[*]}" ]] && echo -e "${RED}ERROR:${OFF} ${YELLOW}Array is empty or not provided.${OFF}" >&2 && exit 0 || \
    [[ "${array_ref[0]}" == "No catch all tags detected." ]] && \
    (( ERROR_LOGGING )) && echo -e "${RED}ERROR:${OFF} ${YELLOW}No catch all tags detected.${OFF}" && return 0

    # Process the second parameter.
    [[ -n "$andOr" ]] && andOr="${andOr} "

    # Print logic.
    printf "@%s" "${array_ref[0]}"
          for tag in "${array_ref[@]:1}"; do
              printf " ${andOr}@%s" "$tag"
          done
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

processSerenityReport() {
# This function is reusable code for processing a Serenity report. For use in other functions.

    # Initial value assignment and error handling.
    url=$1
    report_request=$2
    [[ -n $3 ]] && local DEBUG_LOGGING="$3"
    [ -z "${url}" ] && echo -e "${RED}ERROR:${OFF} ${YELLOW}No value has been passed to the processor for the serenity report link.${OFF} \n" && exit 1

    # Define any optional filters to be used if none are defined in memory.
    [ -z "${filterCondition}" ] && \
    echo -e "${YELLOW}WARN: filterCondition not set, you can set this permanently in the '${OFF}${ORANGE}Declarations.sh${OFF}${YELLOW}' file.${OFF}
            ${PURPLE}Please enter the term you would like to filter tag names by:${OFF}" && \
    read -r user_response && \
    echo -e "${CYAN}Filter condition:${OFF} ${ORANGE}$user_response${OFF}" && \
    filterCondition="${user_response}"

    # Error handling on the filterCondition
    [ -z "${filterCondition}" ] && \
    echo -e "${RED}ERROR:${OFF} ${YELLOW}No value has been set for the filterCondition, script exited.${OFF} \n" && exit 0
    # Alternative command if it later should be required to allow for no specified filter path:
    #[ -z "${filterCondition}" ] && \
    #echo -e "$${YELLOW}WARN: No value has been set for the filterCondition.${OFF} \n" && \
    #filterCondition=".*"

    # Fetch the HTML content and create a list of tags from the returned value. Call the functions and capture results.
    extract_tags_with_names_numbers_and_colours_then_run_checks "$(curl -s "${url}")" $DEBUG_LOGGING

    # Generate output if requested.
    if [[ "${report_request}" =~ "returnReport" ]]; then

        # Echo all values as a single space-separated string.
        echo -e "${CYAN}Final Data Values:${OFF}
                ${CYAN}Total tests run:${OFF} ${ORANGE}${max_value}${OFF}
                ${CYAN}Tests run using the tag(s):${OFF}
                $(printTagsInFormat runner_tag_names "and")

                ${CYAN}Passing Tag Count:${OFF} ${GREEN}${pass_count}${OFF}
                ${CYAN}Failed Tag Count:${OFF} ${RED}${fail_count}${OFF}" | sed 's/^[ \t]*//' | cat

        # Failed tag output in Jenkins usable format.
        if [[ ${#failed_tags[@]} -gt 0 ]]; then
            echo -e "${CYAN}Failed tags:${OFF}
                    $(printTagsInFormat failed_tags "or")" | sed 's/^[ \t]*//' | cat
        else
            echo -e "${CYAN}There were no failing tags found in this report.${OFF}"
        fi

    elif [[ "${report_request}" =~ "returnFailCountAndRunnerTags" ]]; then
        echo "${fail_count}|$(printTagsInFormat runner_tag_names "and")"
    fi
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
