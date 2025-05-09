#!/bin/sh -l

find "$SOURCE_DIR" -name '*.zip' -exec sh -c '
  for zip_file do
    unzip -o "$zip_file" -d "$(dirname "$zip_file")"
    rm "$zip_file"
  done
' sh {} +

python3 ${GITHUB_ACTION_PATH}/bin/query.py > output.json
OUTPUT_FILE=$(jq -r '.output_file' output.json)
OUTPUT_PATH="dist/${TECHNOLOGY}"
mkdir -p ${OUTPUT_PATH}

for ITEM in $(echo ${DEPENDENCY_FILE} | jq -r "select(. != null) | .[]"); do
  pipenv --python $(which python3) && pipenv install -r ${ITEM}
done
pipenv --python $(which python3) && pipenv lock
cat Pipfile.lock
cp Pipfile.lock "${OUTPUT_PATH}/${OUTPUT_FILE}"

ORIGINAL_PATH=$(pwd) \
&& cd "${OUTPUT_PATH}/${OUTPUT_FILE}" \
&& zip -r "${OUTPUT_FILE}.zip" "." \
&& mv "${OUTPUT_FILE}.zip" .. \
&& cd .. \
&& rm -rf "${OUTPUT_FILE}" \
&& cd ${ORIGINAL_PATH}

echo "--> [${TECHNOLOGY}] output: ${OUTPUT_PATH}"
