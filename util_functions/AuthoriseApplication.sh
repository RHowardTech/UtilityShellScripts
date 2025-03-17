#!/opt/homebrew/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

authoriseApplication() {
# This function is reusable code for authorising an application. For use in other functions.

    # Check OS condition.
    operatingSystemCheck "Mac"

    # Defining passed parameters as expected values.
    local path="$1"

    # Check if the path has been defined and printing the appropriate response.
    if [ -z "${path}" ]; then
        echo -e "${RED}Error:${OFF} ${YELLOW}No pathway has been provided for the application to be authorised.${OFF} \n"
        exit 1
    else
      app_name=$(basename "${path}")
      echo -e "\n${CYAN}Authorising the given application:${OFF} ${ORANGE}'${app_name}'${OFF}"
    fi

    # Authorise application
    authorisation_output=$(xattr -d com.apple.quarantine $path 2>&1)
    authorisation_status=$?

    # In cases where there is an error code.
    if [ ${authorisation_status} -ne 0 ]; then

        # Check for specified error message and echo information to the user.
        if echo "$authorisation_output" | grep -q "No such xattr: com.apple.quarantine"; then
            echo -e "${YELLOW}WARN: The ChromeDriver file has already been authorised.${OFF} \n"
            return 0

        # Otherwise stop the script.
        else
          echo -e "${RED}The application has not been authorised, script exited.${OFF} \n"
          exit 1
        fi
    fi

    echo -e "${GREEN}File has been authorised.${OFF}"
    return 0
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
