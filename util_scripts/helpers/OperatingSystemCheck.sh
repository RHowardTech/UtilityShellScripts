#!/usr/bin/env bash
source "${SHELL_SCRIPT_BASE_DIR}/Declarations.sh"

# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

operatingSystemCheck() {
# This function is reusable code for checking if the users defined OS type matches the expected type passed. For use in other functions.

    # Defining passed parameters as expected values.
    local -a expected_os_types=("$@")

    # Check if an expected parameter has been passed.
    [[ ${#expected_os_types[@]} -eq 0 ]] && \
        echo -e "${RED}ERROR:${OFF} ${YELLOW}No 'expected_os_type' values provided.
                Please pass one or more expected OS types as parameters.${OFF}
                " | sed 's/^[ \t]*//' | cat && \
        exit 1

    # Allow override with "Any" or "All"
    if [[ "${expected_os_types[0]}" =~ ^(Any|All)$ ]]; then
        return 0
    fi

    # Detect Operating System type.
    uname_out="$(uname -s)"

        case "${uname_out}" in
            Linux*)
                # Standard Linux or WSL (Windows Subsystem for Linux).
                grep -qi microsoft /proc/version 2>/dev/null && \
                    os_type="WSL" || \  # Detected as WSL.
                    os_type="Linux"     # Native Linux.
                ;;
            Darwin*)
                os_type="macOS"  # macOS (Darwin kernel).
                ;;
            CYGWIN* | Cygwin*)
                os_type="Cygwin"  # Cygwin environment on Windows.
                ;;
            MINGW* | MSYS*)
                os_type="Git Bash"  # Git Bash on Windows (MinGW or MSYS).
                ;;
            *)
                os_type="Unknown"  # Fallback for unrecognized systems.
                ;;
        esac

    echo -e "${CYAN}Operating system detected as:${OFF} ${ORANGE}${os_type}${OFF}"

    #Please list your OS as "Mac", "Windows" or "Linux"

    # Check if global parameter has been defined correctly.
    [[ "${os_type,,}" == "unknown" ]] && \
        echo -e "${RED}ERROR:${OFF} ${YELLOW}Your 'os_type' definition does not match expected types. Unable to proceed with this script.${OFF}
              " | sed 's/^[ \t]*//' | cat && \
        exit 1

    # Match detected operating system against any value in the expected_os_types array.
    for expected in "${expected_os_types[@]}"; do
        [[ "${expected,,}" == "${os_type,,}" ]] && return 0
    done

    echo -e "${RED}ERROR:${OFF} ${YELLOW}Sorry this script is not written in a universal style and cannot be run for your Operating System.${OFF} \n"
    exit 1
}

# ——————————————————————————————————————————————————————————————————————————————————————————————————————
