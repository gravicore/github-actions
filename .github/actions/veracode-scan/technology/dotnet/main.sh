#!/bin/sh -l

set -e

OUTPUT_PATH="dist/${TECHNOLOGY}"

dotnet restore "./${SOURCE_DIR}/${SOURCE_DIR}.${BUILD_TYPE}"

dotnet build \
  --no-restore "./${SOURCE_DIR}/${SOURCE_DIR}.${BUILD_TYPE}" \
  -c Release \
  -p:DebugType=None \
  -p:DebugSymbols=true

dotnet publish \
  --no-build "./${SOURCE_DIR}/${SOURCE_DIR}.${PUBLISH_TYPE}" \
  -c Release \
  -o "${OUTPUT_PATH}/" \
  -p:DebugType=None \
  -p:DebugSymbols=true

# Build exclusion arguments for zip from EXCLUDE_FILES (comma-separated)
EXCLUDE_ARGS=""
if [ -n "$EXCLUDE_FILES" ]; then
  OLDIFS=$IFS
  IFS=,
  # This sets $1, $2, ... to each comma-separated item
  set -- $EXCLUDE_FILES
  IFS=$OLDIFS

  for f in "$@"; do
    # Trim leading spaces (handles "a.dll, b.dll" nicely)
    f=$(echo "$f" | sed 's/^ *//')
    [ -n "$f" ] || continue
    EXCLUDE_ARGS="$EXCLUDE_ARGS -x $f"
  done
fi

# Run zip with or without exclusions
if [ -n "$EXCLUDE_ARGS" ]; then
  # shellcheck disable=SC2086
  zip -r "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/" $EXCLUDE_ARGS
else
  zip -r "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/"
fi

rm -rf "${OUTPUT_PATH}" \
  && mkdir -p "${OUTPUT_PATH}" \
  && mv "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/"

echo "--> ${TECHNOLOGY} output: ${OUTPUT_PATH}"
