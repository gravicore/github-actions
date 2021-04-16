#!/bin/bash

function stripColors {
  echo "${1}" | sed 's/\x1b\[[0-9;]*m//g'
}

function hasPrefix {
  case ${2} in
    "${1}"*)
      true
      ;;
    *)
      false
      ;;
  esac
}

function parseInputs {
  # Required inputs
  if [ "${INPUT_ACTIONS_COMMAND}" != "" ]; then
    gcActionCommand=${INPUT_ACTIONS_COMMAND}

    if [ -z "${NAMESPACE}" ]; then
      echo "NAMESPACE must be defined"
      exit 1
    fi

    if [ ${INPUT_ACTIONS_COMMAND} == "react-publish-s3" ] && ([ -z "${CHAMBER_S3_CDN_BUCKET_ID}" ] || [ -z "${BUILD_DIR}" ]); then
      echo "CHAMBER_S3_CDN_BUCKET_ID and BUILD_DIR must be defined when using react-publish-s3"
      exit 1
    fi

    if [ ${INPUT_ACTIONS_COMMAND} == "react-invalidate-cloudfront" ] && [ -z "${CHAMBER_S3_CDN_DISTRO_ID}" ]; then
      echo "CHAMBER_S3_CDN_DISTRO_ID must be defined when using react-invalidate-cloudfront"
      exit 1
    fi

  else
    echo "Input actions_command cannot be empty"
    exit 1
  fi

  # Optional inputs
  gcWorkingDir="."
  if [[ -n "${INPUT_GC_ACTIONS_WORKING_DIR}" ]]; then
    gcWorkingDir=${INPUT_GC_ACTIONS_WORKING_DIR}
  fi
}

function main {
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
  source ${scriptDir}/react.sh

  parseInputs
  cd ${GITHUB_WORKSPACE}/${gcWorkingDir}

  case "${gcActionCommand}" in
    react-build)
      # installTerragrunt
      reactBuild ${*}
      ;;
    react-unit-tests)
      # installTerragrunt
      reactUnitTests ${*}
      ;;
    react-publish-s3)
      # installTerragrunt
      reactPublishS3 ${*}
      ;;
    react-invalidate-cloudfront)
      # installTerragrunt
      reactInvalidateCloudFront ${*}
      ;;
    *)
      echo "Error: Must provide a valid value for actions_command"
      exit 1
      ;;
  esac
}

main "${*}"
