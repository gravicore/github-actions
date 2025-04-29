#!/bin/sh -l

sh -c "${BUILD_COMMAND}"

# Some projects are creating a dist folder,
# we will clean it up before copying the jar files
mkdir -p dist && rm -rf dist/*
OUTPUT_PATH="dist/${TECHNOLOGY}"
mkdir -p ${OUTPUT_PATH}

# Copy the jar files to the output path
find ${SOURCE_DIR} -type d -name target | while read DIR; do
  find "$DIR" -maxdepth 1 -type f -name "*.jar" -exec cp {} ${OUTPUT_PATH} \;
done

# Remove files that match the IGNORE_PATTERNS
OLD_IFS="${IFS}"
IFS=','
set -f
for pattern in ${IGNORE_PATTERNS}; do
  echo "--> [${TECHNOLOGY}] removing files with pattern: ${pattern}"
  find "${OUTPUT_PATH}" -type f -name "${pattern}" -exec rm -f {} \;
done
IFS="${OLD_IFS}"
set +f

echo "--> [${TECHNOLOGY}] output: ${OUTPUT_PATH}"

if [ -n "${UBER_JAR}" ] && [ "${UBER_JAR}" = "true" ]; then
  echo "--> [${TECHNOLOGY}] creating uber jar..."
  . "$(dirname "$0")/uber.sh"
  echo "--> [${TECHNOLOGY}] created uber jar..."
fi
