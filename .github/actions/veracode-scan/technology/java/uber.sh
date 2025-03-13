#!/bin/sh -l

UBER_PATH="${GITHUB_REPOSITORY##*/}"
OUTPUT_JAR="${UBER_PATH}.jar"

rm -rf "${UBER_PATH}"
mkdir -p "${UBER_PATH}"

find "${OUTPUT_PATH}" -name "*.jar" -print0 | xargs -0 -I {} sh -c '
  echo "--> [${TECHNOLOGY}] extracting {} to ${1}..."
  unzip -q -o "{}" -d "${1}"
' _ "${UBER_PATH}"

echo "--> [${TECHNOLOGY}] creating the uber jar: ${OUTPUT_JAR}"
zip -r "${OUTPUT_JAR}" "${UBER_PATH}" > /dev/null
echo "--> [${TECHNOLOGY}] uber jar created: ${OUTPUT_JAR}"

rm -rf "${OUTPUT_PATH}"
mkdir -p "${OUTPUT_PATH}"
echo "--> [${TECHNOLOGY}] cleaned up: ${OUTPUT_PATH}"

mv "${OUTPUT_JAR}" "${OUTPUT_PATH}"
echo "--> [${TECHNOLOGY}] moved: ${OUTPUT_JAR} to: ${OUTPUT_PATH}"
