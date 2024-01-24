#!/bin/bash

# fail on undefined variables
set -u
# Prevent pipe errors to be silenced
set -o pipefail
# Exit if any command exit as non-zero
set -e
# enable trace mode (print what it does)
# set -x

eval $INPUT_RUN

micromamba install -y -n base python=$INPUT_PYTHON_VERSION git -c conda-forge

# check if INPUT_INSTALL env variable is .yml or .yaml
if [[ -n "$INPUT_ENV" ]]; then
  # run micromamba install command
  micromamba install -y -n base -f "$INPUT_ENV"
fi

cd /tmp

micromamba repoquery whoneeds $INPUT_PACKAGE_NAME -c conda-forge > whoneeds.txt

python get_yml.py

micromamba install -y -n base -f reverse.yaml

micromamba list

# Read packages from packages.txt file
packages=$(cat packages.txt)

cd $GITHUB_WORKSPACE

eval $INPUT_INSTALLATION_COMMAND

counter=0
packages_array=($packages)
# Get the length of the array
total=${#packages_array[@]}

# Declare variables for each category
passed=""
failed=""
no_tests=""

set +e

# Loop through each package and run pytest with pyargs option
for package in $packages
do
    ((counter++))
    echo -e "\n\e[95m================================================================================"
    echo -e "$counter/$total: Running pytest for $package"
    echo -e "\e[95m================================================================================\n"

    if [ "$INPUT_VERBOSE" = "true" ]; then
      pytest --color yes --disable-warnings ${INPUT_PARALLEL:true:+-n auto} --pyargs "$package" -v
    else
      pytest --color yes --disable-warnings --pyargs "$package" --tb=no
    fi

    # Get the exit code
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        passed+="$package, "
    elif [ $exit_code -eq 1 ]; then
        failed+="$package, "
    elif [ $exit_code -eq 5 ]; then
        no_tests+="$package, "
    fi

done

# Print the summary
echo -e "\n\e[1m\e[35m======================= reverse dependency tests summary ======================="
echo -e "\e[32mPASSED: \e[0m${passed%, }"
echo -e "\e[31mFAILED: \e[0m${failed%, }"
echo -e "\e[33mNO TESTS COLLECTED: \e[0m${no_tests%, }"

# check if failed is not empty and FAIL is true
if [[ -n "$failed" && "$INPUT_FAIL_ON_FAILURE" == "true" ]]; then
  # return an error exit code
  exit 1
else
  # pass
  exit 0
fi