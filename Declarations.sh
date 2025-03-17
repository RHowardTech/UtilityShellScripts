# Please see README.md for dependencies details.

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# Universal Declarations

# Pathway to the directory structure that your repositories are kept in.
main_repos_path=""        #"/Users/user.name/IdeaProjects"
#Please list your OS as "Mac", "Windows" or "Linux"
operating_system=""       #"Mac"

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# Chrome Updater Declarations

# This is the pathway defined by homebrew for your chromedriver installation.
#    - If this differs for your system please update this value.
brew_chromeDriver_path="/opt/homebrew/bin/chromedriver"

# Specify the name and pathway of any specific files you with to be updated from the context of your main_repos_path endpoint.
# E.G. If the fully qualified pathway is "/Users/user.name/IdeaProjects/repo-name" then "/Users/user.name/IdeaProjects" is
#      the main_repos_path and "repo-name" should be added to chromeRepos value.
# E.G. If you have a file outside of the structure then if the fully qualified pathway is "/Users/user.name/Documents/repo-name2"
#      then "/Users/user.name/IdeaProjects" is the main_repos_path and "../Documents/repo-name2" should be added to chromeRepos value.
chrome_repos=(
        ""
        ""
        ""
      )

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# Data Replacement Declarations

# Specify the file paths required for various replace data functions. Ensure these are modified and the replacment data specified in the function as
# well as saving the file before running the script!

# Pathway of the repository to make changes in.
replace_data_repo_path=""                 #"UtilityShellScripts"
# Pathway to use as a filter to specify replacement options.
replace_data_directory_filter_path=""     #"products"
# Content to search for to locate all files to be replaced.
replace_data_search_term=""               #"file identifying text"

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# Pre-set Variable Declarations
#     - No need to fill anything here, these are predefined values for the script's printing.

return_location=$(pwd)
countTool=0
user_flag=0
user_response=""

# ——————————————————————————————————————————————————————————————————————————————————————————————————————

# Colour Declarations
#     - No need to fill anything here, these are predefined values for the script's printing.

PURPLE="\033[35;01m";
# Purple is used for direct requests for user entry.

GREEN="\033[32;01m";
# Green is used for successful start, checkpoint and finished messages.

RED="\033[31;01m";
# Red is used for error message alerts.

YELLOW="\033[33;01m";
# Yellow is used for detailing console information, for example an error log to go along with the error alert.

ORANGE="\033[38;5;214m";
# Orange is used to print back various variable values.

CYAN="\033[36;01m";
# Cyan is used for general logging messages that are not important for the user to read.

BLUE="\033[34;01m";
# Blue is used for user options and example inputs.

OFF="\033[0m";
# Termination of colour usage.

# Currently unused colours:
#PINK="\033[38;5;206m";
#MAGENTA="\033[35m";
#WHITE="\033[97m";
#GRAY="\033[90m";
#BOLD="\033[1m"

# ——————————————————————————————————————————————————————————————————————————————————————————————————————