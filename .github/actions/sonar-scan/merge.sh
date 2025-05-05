#!/bin/sh -l

SONAR=${1}
SONAR=$(echo "${SONAR}" | jq -c ".java.path = (if .java.path == \"\" or .java.path == null then \"${DEFAULT_JAVA_PATH}\" else .java.path end)")
SONAR=$(echo "${SONAR}" | jq -c ".java.version = (if .java.version == \"\" or .java.version == null then \"${DEFAULT_JAVA_VERSION}\" else .java.version end)")
SONAR=$(echo "${SONAR}" | jq -c ".java.command = (if .java.command == \"\" or .java.command == null then \"${DEFAULT_JAVA_COMMAND}\" else .java.command end)")
SONAR=$(echo "${SONAR}" | jq -c ".java.pattern = (if .java.pattern == \"\" or .java.pattern == null then \"${DEFAULT_JAVA_PATTERN}\" else .java.pattern end)")
SONAR=$(echo "${SONAR}" | jq -c ".java.[\"ignore-errors\"] = (if .java.[\"ignore-errors\"] == \"\" or .java.[\"ignore-errors\"] == null then \"${DEFAULT_JAVA_IGNORE_ERRORS}\" else .java.[\"ignore-errors\"] end)")
SONAR=$(echo "${SONAR}" | jq -c ".python.path = (if .python.path == \"\" or .python.path == null then \"${DEFAULT_PYTHON_PATH}\" else .python.path end)")
SONAR=$(echo "${SONAR}" | jq -c ".python.version = (if .python.version == \"\" or .python.version == null then \"${DEFAULT_PYTHON_VERSION}\" else .python.version end)")
SONAR=$(echo "${SONAR}" | jq -c ".python.command = (if .python.command == \"\" or .python.command == null then \"${DEFAULT_PYTHON_COMMAND}\" else .python.command end)")
SONAR=$(echo "${SONAR}" | jq -c ".python.pattern = (if .python.pattern == \"\" or .python.pattern == null then \"${DEFAULT_PYTHON_PATTERN}\" else .python.pattern end)")
SONAR=$(echo "${SONAR}" | jq -c ".python.[\"ignore-errors\"] = (if .python.[\"ignore-errors\"] == \"\" or .python.[\"ignore-errors\"] == null then \"${DEFAULT_PYTHON_IGNORE_ERRORS}\" else .python.[\"ignore-errors\"] end)")

SOURCES=$(echo "${SONAR}" | jq -rc '[
  (has("java") as $j | has("python") as $p |
    if $j and $p then "java,python"
    elif $j then "java"
    elif $p then "python"
    else "" end)
  ] | .[0]')

LANGUAGES=$(echo "${SONAR}" | jq -rc '[
  (has("java") as $j | has("python") as $p |
    if $j and $p then "java,py"
    elif $j then "java"
    elif $p then "py"
    else "" end)
  ] | .[0]')

SONAR=$(echo "${SONAR}" | jq -c ".sources = \"${SOURCES}\"")
SONAR=$(echo "${SONAR}" | jq -c ".languages = \"${LANGUAGES}\"")

echo ${SONAR}
