#!/bin/bash

# fail on undefined variables
set -u
# Prevent pipe errors to be silenced
set -o pipefail
# Exit if any command exit as non-zero
set -e
# enable trace mode (print what it does)
set -x

cd /tmp

micromamba repoquery whoneeds $INPUT_PACKAGE_NAME -c conda-forge > whoneeds.txt
# micromamba repoquery whoneeds libpysal -c conda-forge > whoneeds.txt

python get_yml.py

micromamba install -y -n base -f reverse.yaml

cd $GITHUB_WORKSPACE

eval $INPUT_INSTALLATION_COMMAND

cd /tmp

# Read packages from packages.txt file
packages=$(cat packages.txt)

# Loop through each package and run pytest with pyargs option
for package in $packages
do
    echo "Running pytest for $package"
    pytest --color yes --tb=no --pyargs $package || true
done