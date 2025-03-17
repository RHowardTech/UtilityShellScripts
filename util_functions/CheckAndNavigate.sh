#!/opt/homebrew/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

checkAndNavigate() {
# This function is reusable code to check local navigation for errors with a given pathway. For use in other functions.

      # Defining passed parameters as expected values.
      local path="$1"
      local messageDisplayPath="$2"

      # Check that path has been defined.
      if [ -z "${path}" ]; then
          echo -e "${RED}Error:${OFF} ${YELLOW}No value has been provided for the navigation pathway.${OFF} \n"
          exit 1
      fi

      # If messageDisplayPath is not provided then set it to path value.
      if [ "${messageDisplayPath}" ]; then
          messageDisplayPath=$path
      fi

      # Navigate to the given folder, suppress any error messages and respond if there are.
      cd "${path}" 2>/dev/null || {
          echo "${RED}Error:${OFF} ${YELLOW}The file or directory '${OFF}${ORANGE}${messageDisplayPath}${OFF}${YELLOW}' could not be found, check defined file references.${OFF}"
          exit 1
      }

      return 0
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
