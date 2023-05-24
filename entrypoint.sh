#!/bin/bash

# fail on undefined variables
set -u
# Prevent pipe errors to be silenced
set -o pipefail
# Exit if any command exit as non-zero
# set -e
# enable trace mode (print what it does)
# set -x

cd /tmp

micromamba repoquery whoneeds $INPUT_PACKAGE_NAME -c conda-forge > whoneeds.txt

python get_yml.py

micromamba install -y -n base -f reverse.yaml

cd $GITHUB_WORKSPACE

eval $INPUT_INSTALLATION_COMMAND

cd /tmp

# Read packages from packages.txt file
packages=$(cat packages.txt)

declare -A results

# Loop through each package and run pytest with pyargs option
for package in $packages
do
    echo -e "\nRunning pytest for $package\n"

    pytest --color yes --tb=no --disable-warnings -n auto --pyargs $package

    # Get the exit code
    exit_code=$?
    # Store the exit code in the array with the package name as the key
    results[$package]=$exit_code

done

# Print the summary
echo -e "\nSummary:"
# Loop through the array
for package in "${!results[@]}"
do
    # Print the package name and the exit code
    echo "$package: ${results[$package]}"
done