#!/bin/sh -l

OUTPUT_PATH="dist/${TECHNOLOGY}"

dotnet restore "./${SOURCE_DIR}/${SOURCE_DIR}.${BUILD_TYPE}"

dotnet build \
  --no-restore "./${SOURCE_DIR}/${SOURCE_DIR}.${BUILD_TYPE}" \
  -p:DebugType=None \
  -p:DebugSymbols=true

dotnet publish \
  --no-build "./${SOURCE_DIR}/${SOURCE_DIR}.${PUBLISH_TYPE}" \
  -o "${OUTPUT_PATH}/" \
  -p:DebugType=None \
  -p:DebugSymbols=true

# Build exclusion arguments for zip
EXCLUDE_ARGS=""
IFS=',' read -ra FILES_TO_EXCLUDE <<< "$EXCLUDE_FILES"
for f in "${FILES_TO_EXCLUDE[@]}"; do
  if [ -n "$f" ]; then
    EXCLUDE_ARGS="$EXCLUDE_ARGS -x $f"
  fi
done

# Create ZIP with exclusions
zip -r "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/" $EXCLUDE_ARGS

# Rebuild output folder and move ZIP inside it
rm -rf "${OUTPUT_PATH}"
mkdir -p "${OUTPUT_PATH}"
mv "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/"

echo "--> ${TECHNOLOGY} output: ${OUTPUT_PATH}"
