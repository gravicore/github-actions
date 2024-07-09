#!/bin/sh -l

sh -c "${BUILD_COMMAND} -f ${SOURCE_DIR}"
OUTPUT_PATH="dist/${TECHNOLOGY}"
mkdir -p ${OUTPUT_PATH}
cp ${SOURCE_DIR}/*/target/*.jar ${OUTPUT_PATH}

echo "--> [${TECHNOLOGY}] output: ${OUTPUT_PATH}"
