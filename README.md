# Utility Shell Scripts
This is a collection of utility scripts.

This is a bash script designed primarily for use on **Mac devices**, however some scripts may be usable on other OS.

## Script Requirements / Dependencies

This script assumes the following in order to function properly:
  1) That you have updated the Declarations section of the bash file with your local system's values.
  2) The script assumes that all the repositories that you wish to update are stored in a central localtion. If not then you can specify detailed pathways in the various file definition sections.
  3) That you have the following software installed. 
     1) Homebrew (https://brew.sh/).
     2) Bash-v4+ (https://www.gnu.org/software/bash/) .
     3) Fuzzy finder (https://github.com/junegunn/fzf). 
     4) JQ (https://jqlang.org/download/).

You can also use Homebrew to install these software programs with commands:
  ```
  brew install fzf
  brew install bash
  brew install jq
  ```

## Running This Script

After downloading this script and updating the dependencies as mentioned above the script can be run with the given base command below followed by one of several given additional parameters to trigger different functionality.
```
bash path/to/file/fileName.sh <insert_additional_parameter>
```
If you do not define an additional parameter instructions will be printed to show the different functionality that is available.

## FAQs / Troubleshooting

  1) Depending on your system shell and path layout you may need to adjust the bash shebang command at the top of the shell scripts from this:
```
#!/bin/bash 
``` 
To this:
```
#!/opt/homebrew/bin/bash
```