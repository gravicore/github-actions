#!/bin/sh -l

OUTPUT_PATH="dist/${TECHNOLOGY}"
mkdir -p ${OUTPUT_PATH}

yarn install --cwd ${SOURCE_DIR}
rm -rf ${SOURCE_DIR}/node_modules/

find ${SOURCE_DIR} -type f \( \
    -name "*.asp" \
    -o -name "*.css" \
    -o -name "*.ehtml" \
    -o -name "*.es" \
    -o -name "*.es6" \
    -o -name "*.handlebars" \
    -o -name "*.hbs" \
    -o -name "*.hjs" \
    -o -name "*.htm" \
    -o -name "*.html" \
    -o -name "*.js" \
    -o -name "*.jsx" \
    -o -name "*.json" \
    -o -name "*.jsp" \
    -o -name "*.map" \
    -o -name "*.mustache" \
    -o -name "*.php" \
    -o -name "*.ts" \
    -o -name "*.tsx" \
    -o -name "*.vue" \
    -o -name "*.xhtml" \
    -o -name "npm-shrinkwrap.json" \
    -o -name "package-lock.json" \
    -o -name "package.json" \
    -o -name "yarn.lock" \
\) -exec zip ${OUTPUT_PATH}/veracode_static_sast_$(date +%Y%m%d).zip {} +

echo "--> ${TECHNOLOGY} output: ${OUTPUT_PATH}"
