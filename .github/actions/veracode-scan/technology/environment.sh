#!/bin/sh -l

echo "--> [${1}] setting environment"
KEY=${1}
VALUE=${2}

export TECHNOLOGY=${KEY}
export SOURCE_DIR=$(echo ${VALUE} | jq -r ".\"source-dir\" // \"${DEFAULT_MODULE:-${TECHNOLOGY}}\"")
export BUILD_COMMAND=$(echo ${VALUE} | jq -r ".\"build-command\" // \"\"" | tr -d '\n')
export IGNORE_FILES=$(echo ${VALUE} | jq -r ".\"ignore-files\" // \"\"" | tr -d '\n')
export IGNORE_DIRS=$(echo ${VALUE} | jq -r ".\"ignore-dirs\" // \"\"" | tr -d '\n')
export IGNORE_PATTERNS=$(echo ${VALUE} | jq -r ".\"ignore-patterns\" // \"\"" | tr -d '\n')
export DEPENDENCY_FILE=$(echo ${VALUE} | jq -rc ".\"dependency-file\"")
export UBER_JAR=$(echo ${VALUE} | jq -r ".\"uber-jar\" // \"\"" | tr -d '\n')

for PARAM in TECHNOLOGY SOURCE_DIR BUILD_COMMAND IGNORE_FILES IGNORE_DIRS IGNORE_PATTERNS DEPENDENCY_FILE UBER_JAR; do
  echo "${PARAM}=${!PARAM}"
done
echo "--> [${TECHNOLOGY}] environment set"
