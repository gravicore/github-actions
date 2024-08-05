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

zip -r "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/" \
&& rm -rf "${OUTPUT_PATH}" \
&& mkdir -p "${OUTPUT_PATH}" \
&& mv "${OUTPUT_PATH}.zip" "${OUTPUT_PATH}/"

echo "--> ${TECHNOLOGY} output: ${OUTPUT_PATH}"
