#!/bin/bash

# fail on undefined variables
set -u
# Prevent pipe errors to be silenced
set -o pipefail
# Exit if any command exit as non-zero
set -e
# enable trace mode (print what it does)
set -x

micromamba install -y -n base python -c conda-forge
eval "$(micromamba shell hook --shell=bash)"
micromamba activate base

# micromamba repoquery whoneeds $INPUT_PACKAGE_NAME -c conda-forge > whoneeds.txt
micromamba repoquery whoneeds libpysal -c conda-forge > whoneeds.txt

python get_yml.py

micromamba create -f reverse.yml

micromamba activate reverse