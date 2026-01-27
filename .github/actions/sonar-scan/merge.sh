#!/bin/sh -l

SONAR=${1}

if echo "${SONAR}" | jq -e 'has("java")' > /dev/null; then
  SONAR=$(echo "${SONAR}" | jq -c ".java.path = (if .java.path == \"\" or .java.path == null then \"${DEFAULT_JAVA_PATH}\" else .java.path end)")
  SONAR=$(echo "${SONAR}" | jq -c ".java.version = (if .java.version == \"\" or .java.version == null then \"${DEFAULT_JAVA_VERSION}\" else .java.version end)")
  SONAR=$(echo "${SONAR}" | jq -c ".java.command = (if .java.command == \"\" or .java.command == null then \"${DEFAULT_JAVA_COMMAND}\" else .java.command end)")
  SONAR=$(echo "${SONAR}" | jq -c ".java.pattern = (if .java.pattern == \"\" or .java.pattern == null then \"${DEFAULT_JAVA_PATTERN}\" else .java.pattern end)")
  SONAR=$(echo "${SONAR}" | jq -c ".java.[\"ignore-errors\"] = (if .java.[\"ignore-errors\"] == \"\" or .java.[\"ignore-errors\"] == null then \"${DEFAULT_JAVA_IGNORE_ERRORS}\" else .java.[\"ignore-errors\"] end)")

  # Parse version to detect GraalVM prefix (e.g., "graalvm-22" -> distribution: "graalvm", parsed_version: "22")
  JAVA_VERSION=$(echo "${SONAR}" | jq -r '.java.version')
  if echo "${JAVA_VERSION}" | grep -q "^graalvm-"; then
    JAVA_DISTRIBUTION="graalvm"
    JAVA_PARSED_VERSION=$(echo "${JAVA_VERSION}" | sed 's/^graalvm-//')
  else
    JAVA_DISTRIBUTION="temurin"
    JAVA_PARSED_VERSION="${JAVA_VERSION}"
  fi
  SONAR=$(echo "${SONAR}" | jq -c ".java.distribution = \"${JAVA_DISTRIBUTION}\"")
  SONAR=$(echo "${SONAR}" | jq -c ".java.parsed_version = \"${JAVA_PARSED_VERSION}\"")
fi

if echo "${SONAR}" | jq -e 'has("python")' > /dev/null; then
  SONAR=$(echo "${SONAR}" | jq -c ".python.path = (if .python.path == \"\" or .python.path == null then \"${DEFAULT_PYTHON_PATH}\" else .python.path end)")
  SONAR=$(echo "${SONAR}" | jq -c ".python.version = (if .python.version == \"\" or .python.version == null then \"${DEFAULT_PYTHON_VERSION}\" else .python.version end)")
  SONAR=$(echo "${SONAR}" | jq -c ".python.command = (if .python.command == \"\" or .python.command == null then \"${DEFAULT_PYTHON_COMMAND}\" else .python.command end)")
  SONAR=$(echo "${SONAR}" | jq -c ".python.pattern = (if .python.pattern == \"\" or .python.pattern == null then \"${DEFAULT_PYTHON_PATTERN}\" else .python.pattern end)")
  SONAR=$(echo "${SONAR}" | jq -c ".python.[\"ignore-errors\"] = (if .python.[\"ignore-errors\"] == \"\" or .python.[\"ignore-errors\"] == null then \"${DEFAULT_PYTHON_IGNORE_ERRORS}\" else .python.[\"ignore-errors\"] end)")
fi

if echo "${SONAR}" | jq -e 'has("javascript")' > /dev/null; then
  SONAR=$(echo "${SONAR}" | jq -c ".javascript.path = (if .javascript.path == \"\" or .javascript.path == null then \"${DEFAULT_JAVASCRIPT_PATH}\" else .javascript.path end)")
  SONAR=$(echo "${SONAR}" | jq -c ".javascript.version = (if .javascript.version == \"\" or .javascript.version == null then \"${DEFAULT_JAVASCRIPT_VERSION}\" else .javascript.version end)")
  SONAR=$(echo "${SONAR}" | jq -c ".javascript.command = (if .javascript.command == \"\" or .javascript.command == null then \"${DEFAULT_JAVASCRIPT_COMMAND}\" else .javascript.command end)")
  SONAR=$(echo "${SONAR}" | jq -c ".javascript.pattern = (if .javascript.pattern == \"\" or .javascript.pattern == null then \"${DEFAULT_JAVASCRIPT_PATTERN}\" else .javascript.pattern end)")
  SONAR=$(echo "${SONAR}" | jq -c ".javascript.[\"ignore-errors\"] = (if .javascript.[\"ignore-errors\"] == \"\" or .javascript.[\"ignore-errors\"] == null then \"${DEFAULT_JAVASCRIPT_IGNORE_ERRORS}\" else .javascript.[\"ignore-errors\"] end)")
fi

SOURCES=$(echo "${SONAR}" | jq -rc "[
  (has(\"java\") as \$jv | has(\"python\") as \$py | has(\"javascript\") as \$js |
    if \$jv and \$py and \$js then \"\(.java.path),\(.python.path),\(.javascript.path)\"
    elif \$jv and \$py then \"\(.java.path),\(.python.path)\"
    elif \$jv and \$js then \"\(.java.path),\(.javascript.path)\"
    elif \$py and \$js then \"\(.python.path),\(.javascript.path)\"
    elif \$jv then \"\(.java.path)\"
    elif \$py then \"\(.python.path)\"
    elif \$js then \"\(.javascript.path)\"
    else \"\" end)
  ] | .[0]")

LANGUAGES=$(echo "${SONAR}" | jq -rc "[
  (has(\"java\") as \$jv | has(\"python\") as \$py | has(\"javascript\") as \$js |
    if \$jv and \$py and \$js then \"java,py,js\"
    elif \$jv and \$py then \"java,py\"
    elif \$jv and \$js then \"java,js\"
    elif \$py and \$js then \"py,js\"
    elif \$jv then \"java\"
    elif \$py then \"py\"
    elif \$js then \"js\"
    else \"\" end)
  ] | .[0]")

SONAR=$(echo "${SONAR}" | jq -c ".sources = \"${SOURCES}\"")
SONAR=$(echo "${SONAR}" | jq -c ".languages = \"${LANGUAGES}\"")

echo ${SONAR}
