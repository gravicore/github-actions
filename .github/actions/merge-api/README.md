# merge-api

This action merges an AppSync API into an AppSync Merged API. You can configure it by setting either AWS access keys from a user, an AWS temporary credential or an AWS profile.

### parameters

-   **results**: _required_. the **AWS SSM Parameter** or the actual values of the AppSync API to merge
-   **region**: _optional_. defaults to `us-east-1`. the AWS region
-   **decrypt**: _optional_. defaults to `true`. if the **AWS SSM Parameters** should be decrypted
-   **access_key_id**: _optional_. if not set, **profile** is mandatory
-   **secret_access_key**: _optional_. if not set, **profile** is mandatory
-   **session_token**: _optional_. if not set, it simply won't be used
-   **profile**: _optional_. if not set, **access_key_id** and **secret_access_key** are mandatory
-   **resolve_values**: _optional_. defaults to `false`. if **source** and **target** should be resolved from **AWS SSM**

### how to test

Requires the installation of `local-action`(https://github.com/github/local-action). Once it's installed, check the values you want to set in the `.env` file and run the following:

```
yarn install
local-action run .github/actions/merge-api . .github/actions/merge-api/.env
```

### how to build

```
yarn install
yarn package
```
