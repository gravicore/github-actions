#!/bin/bash

function reactBuild {

  chamberOutput=$(chamber export ${NAMESPACE}-${DEPLOYMENT_STAGE} -f dotenv | grep -e AWS_REGION -e ADMIN_COGNITO_USER_POOL_ID -e ADMIN_COGNITO_CLIENT_ID -e ADMIN_COGNITO_IDENTITY_POOL_ID -e ADMIN_COGNITO_DOMAIN_NAME -e ADMIN_APPSYNC_URIS -e ADMIN_DATADOG_RUM_CLIENT_TOKEN -e ADMIN_DATADOG_RUM_APPLICATION_ID > .env)
  chamberExitCode=${?}
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${chamberExitCode} -ne 0 ]; then
    echo "react-build: error: chamber export failed"
    echo "${chamberOutput}"
    echo
    exit ${chamberExitCode}
  fi
  
  sed -i -e 's/^/REACT_APP_/' .env && cat .env
  yarnOutput=$(yarn install)
  yarnExitCode=${?}
  
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${yarnExitCode} -ne 0 ]; then
    echo "react-build: error: yarn install failed"
    echo "${yarnOutput}"
    echo
    exit ${yarnExitCode}
  fi

  yarnOutput=$(CI=false yarn run build)
  yarnExitCode=${?}

  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${yarnExitCode} -ne 0 ]; then
    echo "react-build: error: yarn run build failed"
    echo "${yarnOutput}"
    echo
    exit ${yarnExitCode}
  fi

  exit ${yarnExitCode}
}

function reactUnitTests {

  chamberOutput=$(chamber export ${NAMESPACE}-${DEPLOYMENT_STAGE} -f dotenv | grep -e AWS_REGION -e ADMIN_COGNITO_USER_POOL_ID -e ADMIN_COGNITO_CLIENT_ID -e ADMIN_COGNITO_IDENTITY_POOL_ID -e ADMIN_COGNITO_DOMAIN_NAME -e ADMIN_APPSYNC_URIS -e ADMIN_DATADOG_RUM_CLIENT_TOKEN -e ADMIN_DATADOG_RUM_APPLICATION_ID > .env)
  chamberExitCode=${?}
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${chamberExitCode} -ne 0 ]; then
    echo "react-unit-tests: error: chamber export failed"
    echo "${chamberOutput}"
    echo
    exit ${chamberExitCode}
  fi
  
  sed -i -e 's/^/REACT_APP_/' .env && cat .env
  yarnOutput=$(echo CI=true yarn test --color)
  yarnExitCode=${?}
  
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${yarnExitCode} -ne 0 ]; then
    echo "react-unit-tests: error: yarn test"
    echo "${yarnOutput}"
    echo
    exit ${yarnExitCode}
  fi
}

function reactPublishS3 {

  chamberOutput=$(chamber exec ${NAMESPACE}-${DEPLOYMENT_STAGE} -- env | grep -e ${CHAMBER_S3_CDN_BUCKET_ID})
  chamberExitCode=${?}
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${chamberExitCode} -ne 0 ]; then
    echo "react-publish-s3: error: chamber exec failed"
    echo "${chamberOutput}"
    echo
    exit ${chamberExitCode}
  fi
  export ${chamberOutput}
  export CHAMBER_S3_CDN_BUCKET_ID=`printenv ${CHAMBER_S3_CDN_BUCKET_ID}`

  awsOutput=$(aws s3 sync ${BUILD_DIR} s3://${CHAMBER_S3_CDN_BUCKET_ID}/ --acl "public-read" --delete)
  awsExitCode=${?}
  
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${awsExitCode} -ne 0 ]; then
    echo "react-publish-s3: error: aws s3 sync failed"
    echo "${awsOutput}"
    echo
    exit ${awsExitCode}
  fi
}

function reactInvalidateCloudFront {

  chamberOutput=$(chamber exec ${NAMESPACE}-${DEPLOYMENT_STAGE} -- env | grep -e ${CHAMBER_S3_CDN_DISTRO_ID})
  chamberExitCode=${?}
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${chamberExitCode} -ne 0 ]; then
    echo "react-invalidate-cloudfront: error: chamber exec failed"
    echo "${chamberOutput}"
    echo
    exit ${chamberExitCode}
  fi
  export ${chamberOutput}
  export CHAMBER_S3_CDN_DISTRO_ID=`printenv ${CHAMBER_S3_CDN_DISTRO_ID}`

  awsOutput=$(aws cloudfront create-invalidation --distribution-id ${CHAMBER_S3_CDN_DISTRO_ID} --paths "/*")
  awsExitCode=${?}
  
  # Exit code of 0 indicates success. Print the output and exit.
  if [ ${awsExitCode} -ne 0 ]; then
    echo "react-invalidate-cloudfront: error: aws cloudfront create-invalidation failed"
    echo "${awsOutput}"
    echo
    exit ${awsExitCode}
  fi
}