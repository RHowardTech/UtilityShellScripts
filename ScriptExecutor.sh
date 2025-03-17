#!/bin/bash
BASE_DIR="$(dirname "$(readlink -f "$0")")"
source "${BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.
# Remember to complete the Dependency section before running any scripts.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
# This section is the general executor for the script.
# It controls the products and methods that will be called based on user selection.

sigIntCatcher(){
# This function checks that there is a populated value passed.
    if [ -z "$1" ]; then
        echo -e "${RED}SigIntCatcherError:${OFF} ${YELLOW}no value passed.${OFF}"
        exit
    fi
}

selectFunction(){
# This function displays the methods available in the chosen method.

    # Defining passed parameters as expected values.
    local product="$1"

    # This loop will select the method for execution based on user selection.
    while true; do
        # Set the path for the JSON config File
        configFile="${BASE_DIR}/product_listings/"$(echo $product | sed 's/ /_/g')".json"

        # Get the list of methods from the config file and add a 'back' option.
        methods=($(jq -r 'keys_unsorted[]' $configFile) "back")

        # Let the user select a method using fzf.
        method=$(echo "${methods[@]}" | sed 's/ /\n/g' | fzf --height ~100% --border=rounded --border-label="$(printf " Select method from ${ORANGE}%s${OFF} you wish to execute " "${product}")")

            case "$method" in
                back)
                    break
                    ;;
                *)
                    # Ensure the method exists in the config file.
                    sigIntCatcher "$method"

                    # Get the corresponding command to execute from the JSON file.
                    cmd=$(jq -r --arg method "$method" '.[$method]' "$configFile")

                    # Ensure the command is not empty.
                    if [ -n "$cmd" ]; then
                        # Execute the command.
                        echo -e "${CYAN}-----------------------------------------------------------------------------------------------------${OFF}
                        ${GREEN}Executing the '${OFF}${ORANGE}${method}${OFF}${GREEN}' method from the '${OFF}${ORANGE}${product}${OFF}${GREEN}' product:${OFF}
                        ${ORANGE}${BASE_DIR}/products/${method}.sh $cmd${OFF}" | sed 's/^[ \t]*//' | cat
                        "${BASE_DIR}""/products/""${method}"".sh" "${cmd}"
                    else
                        echo "${RED}Error:${OFF} ${YELLOW}No command found for method${OFF} ${ORANGE}${method}${OFF}"
                        exit 1
                    fi
                    ;;
            esac
    done
    echo -e "
    ${GREEN}Thank you for using this utility script.${OFF}
    ${CYAN}-----------------------------------------------------------------------------------------------------${OFF}
    " | sed 's/^[ \t]*//' | cat
}

# First time user prompt.
if [[ -z "${operating_system}" || -z "${main_repos_path}" ]]; then
    echo -e "
            ${PURPLE}Welcome to the utilScriptRunner, if this is your first time using the script please review the ${OFF}${BLUE}README.md${OFF}${PURPLE} file to check dependencies.
            Also please fill out the required variables in the ${OFF}${BLUE}Declarations.sh${OFF}${PURPLE} file.
            At a minimum the ${OFF}${BLUE}Universal Declarations${OFF}${PURPLE} section must be filled in to continue.${OFF}
            " | sed 's/^[ \t]*//' | cat
    exit 1
fi

# This loop will select the product that for browsing based on user selection.
while true; do
    # Get the list of product files from the directory and add an 'exit' option
    products=($(ls $BASE_DIR/product_listings/ | grep '\.json$' | cut -f 1 -d '.') "exit")
    [ -z "$1" ] && \
        product=$(echo "${products[@]}" | sed -e 's/ /\n/g' -e 's/_/ /g' | fzf --height ~100% --border=rounded --border-label=" Select the product you wish to use ") ||
        product="$1"
    case "$product" in
        exit)
            exit
            ;;
        *)
            sigIntCatcher "$product"
            selectFunction "$product"
            ;;
    esac
done

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
