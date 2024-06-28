#!/bin/sh -l

sh -c "${BUILD_COMMAND}"
mkdir dist
cp ${SOURCE_DIR}/*/target/*.jar dist

echo "output-path=dist" >> $GITHUB_OUTPUT
