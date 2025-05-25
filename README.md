# QA Utility Script README
This directory contains an array of utility scripts with various purposes.

These are primarily bash scripts however the system has been built to allow for .py or .jar files to be run in the same system.

Some of these script are also designed for use on **macOS Devices Only**.

## Script Requirements / Dependencies

This script assumes the following in order to function properly:
1) The script assumes that all the repositories that you wish to work with are stored in a central location within the folder structure **~/IdeaProjects**.
2) Some scripts may have additional ReadMe files, ensure to read any related files before using the scripts to ensure you have covered any required dependencies.
3) Some scripts may require you to locally edit their values saved in **Declarations.sh**, if required the script will prompt you to do so at run time.
4) That you have The following software installed.
     1) Homebrew (https://brew.sh/) for macOS users only.
     2) Scoop (https://scoop.sh/) for Windows users only.
     3) Bash-v4+ (https://www.gnu.org/software/bash/)
     4) Fuzzy finder (https://github.com/junegunn/fzf)
     5) Jq (https://jqlang.org/download/)

If you are using macOS you can also use Homebrew to install these programs with commands:
  ```
  brew install fzf
  brew install bash
  brew install jq
  ```

If you are using Windows you can also use Scoop to install these programs with commands:
  ```
  scoop install git        #(Required for Scoop itself).
  scoop install fzf
  scoop install jq
  ```

## Running This Script

After downloading this script and updating the dependencies as mentioned above the script executor can be run with the command below to trigger different functionality. When running this script it is best to do so from your machine's root context rather than the context of the repository.
```
path/to/file/ScriptExecutor.sh
```
Note that there may be scripts that have not been added to the script executor's 'catalogue_of_scripts'. For these cases you will need to check the individual scripts for instructions on use.

Also worth being aware of is there are log controllers that can also be found in the **ScriptExecutor.sh** file that will control logging output.

## Adding New Scripts

The 'ScriptExecutor' is capable of executing any type of script as long as the logic for execution is contained inside the script. <br />
E.G. for bash scripts they have the starting shebang command **#!/usr/bin/env bash** to let the system know how to execute them.

Assuming this rule has been followed then you can add a new entry under one of the files in the directory 'catalogue_of_scripts'.

Note the reference must be in the format:
```
"File-Name.extension": "functionName"
```

That being done you can copy the Template.sh file to make set up of new bash scripts a bit easier.

For new scripts please conform to using the Colour and Logging controllers as defined in the **ScriptExecutor.sh** file.

## FAQs / Troubleshooting

1) If using brew you may need to adjust the shell usage of bash from **#!/bin/bash** to **#!/opt/homebrew/bin/bash** depending on your systems shell and path layouts. <br />
   Preferably redirect your local system's pathing to look for the base version of bash in your brew directory. <br />
   This can be done by confirming that your brew path is listed in your allowed shells, if not add it and then change the login shell for your user account. <br />
   The three commands for these actions are listed below.
   ```
   cat /etc/shells
        
   sudo bash -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
        
   chsh -s /opt/homebrew/bin/bash
   ```

2) If you should run into trouble using the following commands:
   ```
   git update-index --assume-unchanges ${FilePath}
   git update-index --no-assume-unchanged ${FilePath}
   ```
   Use this command to restore the working tree file paths.
   If a path is tracked but does not exist in the restore source, it will be removed to match the source.
   ```
   git restore .
   ```

3) If running the scripts using a Windows OS you may find that your scripts are opening in separate terminal windows 
   and closing immediately on error before you can read the code.
   
   As a work-around to this you can run the main executor script with the following command:
   
   ```
   "Path/To/bash.exe" --noprofile --norc "Path/To/ScriptExecutor.sh"
   ```

3) Add further FAQs here...