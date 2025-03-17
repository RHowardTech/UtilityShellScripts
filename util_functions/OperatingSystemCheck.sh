#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

operatingSystemCheck() {
  # This function is reusable code for checking if the users defined OS type matches the expected type passed. For use in other functions.
  # When calling this script define the OS systems that will function in the calling check.

      # Defining passed parameters as expected values.
      local expected_os_type="$1"
      local secondary_expected_os_type="$2"

      # Check if an expected parameter has been passed.
      if [[ -z "${expected_os_type}" ]]; then
          echo -e "${RED}Error:${OFF} ${YELLOW}This command has been passed without an 'expected_os_type',
                  please check the function call and define an expected type with a parameter.${OFF}
                  " | sed 's/^[ \t]*//' | cat
          exit 1
      fi

      # Check if global parameter has been defined correctly.
      if [[ "${operating_system,,}" != "mac" && "${operating_system,,}" != "windows" && "${operating_system,,}" != "linux" ]]; then
          echo "${RED}Error:${OFF} ${YELLOW}Your 'operating_system' definition does not match expected types. Please redefine as one of the following:${OFF}
                ${ORANGE}Mac${OFF}
                ${ORANGE}Windows${OFF}
                ${ORANGE}Linux${OFF}
                " | sed 's/^[ \t]*//' | cat
          exit 1
      fi

      # Check the expected parameter against global definition.
      if [[ "${expected_os_type,,}" != "${operating_system,,}" && "${secondary_expected_os_type,,}" != "${operating_system,,}" ]]; then
          echo -e "${RED}Error:${OFF} ${YELLOW}Sorry this script is not written in a universal style and cannot be run for your Operating System.${OFF} \n"
          exit 1
      fi
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
