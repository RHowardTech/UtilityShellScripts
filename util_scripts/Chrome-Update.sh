#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")/.."
source "${BASE_DIR}/Declarations.sh"
source "${BASE_DIR}/util_scripts/util_helpers/AuthoriseApplication.sh"
source "${BASE_DIR}/util_scripts/util_helpers/CheckAndNavigate.sh"
source "${BASE_DIR}/util_scripts/util_helpers/OperatingSystemCheck.sh"
source "${BASE_DIR}/util_scripts/util_helpers/UpgradeChromeDriverViaBrew.sh"
source "${BASE_DIR}/util_scripts/util_helpers/ChromeLink.sh"


# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

updateChromeDriverAndCreateNewLinks() {
# This function update's Brew's copy of ChromeDriver and then replaces all linked copies of the chromedriver file with a
# new copy if the Repos are directly inside your specified main_repos_path or defined in the chrome_repos declaration.

    # Operating system check, this script will only work for Mac.
    operatingSystemCheck "Mac"

    #Update Brew's chromeDriver:
    # Capture the output from the command, adjust the output to capture the terminal message rather than the exist code.
    echo -e "\n${GREEN}ChromeDriver General Update Started!${OFF} \n"

    # Execute the upgrade script.
    upgradeChromeDriverViaBrew

    # Execute the authorisation script.
    authoriseApplication "${brew_chromeDriver_path}"

    # Define variable array to contain confirmed matched directories for later use.
    confirmed_directories=()

    # Navigate to the repos directory and generate list.
    checkAndNavigate "${main_repos_path}"
    repo_list=($(ls -1))
    target_file="chromedriver"


    # Loop to check for and reset all chromeDriver copies.
    echo -e "${GREEN}ChromeDriver linking from main directory started:${OFF}"
    for dir in "${repo_list[@]}"; do
    file_directory=$(dirname "${dir}")

      #Cycle into each file check if the file is a directory.
      if [ -d "${dir}" ]; then

          #If so then it navigated into the file and checks if the chromeDriver is present.
          if [ -f "${dir}/${target_file}" ]; then
              echo -e "${CYAN}Found${OFF} ${ORANGE}${target_file}${OFF} ${CYAN}in directory: '${OFF}${ORANGE}${dir}${OFF}${CYAN}', updating reference now:${OFF}"
              confirmed_directories+=("${ORANGE}${file_directory}${OFF}")
              checkAndNavigate "$dir"

              echo -e "${CYAN}Removing old file.${OFF}"
              rm "$target_file"
              echo -e "${CYAN}Linking new file.${OFF}"
              link_output=$(ln -s "${brew_chromeDriver_path}" chromedriver 2>&1)

              # Error handling
              if [[ $link_output == "ln: chromedriver: No such file or directory" ]]; then
                  echo -e "${RED}Error:${OFF}${YELLOW} No such file or directory.${OFF}
                          ${YELLOW}ChromeDriver pathway is likely incorrectly defined, please check declarations. Exiting script.${OFF}
                          " | sed 's/^[ \t]*//' | cat
                  exit 1
              fi

              echo -e "${CYAN}Opening ChromeDriver to confirm functionality.${OFF}"
              ./chromedriver > /dev/null 2>&1 &
              ProcessID=$!
              # Code Breakdown:
              #     ./chromedirver    Opens the chromedriver file.
              #     > /dev/null       Redirects standard output to dev/null silencing the output.
              #     2>&1              Redirects standard errors to standard output.
              #     &                 Runs the command in the background.
              #     ProcessID=$!      Storing the output of the last executed background command in the ProcessId variable.

              # Defining a timeout for the while loop:
              TIMEOUT=10
              START_TIME=$SECONDS

              while true; do
                  sleep 1

                  # Confirmation of a successful start.
                  if ps aux | grep -i "chromedriver" | grep -q "ChromeDriver was started successfully"; then
                        echo -e "${GREEN}ChromeDriver was started successfully.${OFF} \n"
                        break

                  # If the process has not cleared end the process and notify the user.
                  elif (( SECONDS - START_TIME >= TIMEOUT)); then
                      echo -e "${RED}Timeout reached:${OFF} ${YELLOW}Exiting the ChromeDriver checking loop for ${OFF}${ORANGE}${dir}${OFF}${YELLOW}, suggest manually confirming that the file copy is functioning.${OFF} \n"
                      kill -SIGINT $ProcessID
                      break
                  fi
              done

              # Navigate up a level to continue the checking of other repositories.
              checkAndNavigate ../
          fi
      fi
    done

    # Assuming some values where found pass them to the link function. Otherwise run the link function with no input.
    if [ ${#confirmed_directories[@]} -eq 0 ]; then
        createLinkToBrewChromeDriverFromList "${confirmed_directories[@]}"
    else
        createLinkToBrewChromeDriverFromList
    fi

    # Close the script.
    checkAndNavigate "$return_location"
    echo -e "${GREEN}ChromeDriver General Update Complete!${OFF} \n"
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# This section contains the local executor for the ChromeDriverUpdates.sh script.

method_name="$1"


# Check that a value has been passed.
if [ -z "$method_name" ]; then
    echo -e "${RED}Error:${OFF} ${YELLOW}No parameter passed for method selection. Choose a valid option:${OFF}
            ${ORANGE}updateChromeDriverAndCreateNewLinks${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi

# Ensure that the value has been passed as a function.
if declare -F "$1" > /dev/null; then
    "$1"
else
    echo -e "${RED}Error:${OFF} ${YELLOW}Invalid method selection. Choose from:${OFF}
            ${ORANGE}updateChromeDriverAndCreateNewLinks${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi
