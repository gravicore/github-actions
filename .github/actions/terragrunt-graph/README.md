# terragrunt-graph

This action creates a graph of dependencies for Terragrunt resources.

### parameters

-   **directory**: _optional_. defaults to `.terragrunt`. the directory to find terragrunt files
-   **filename**: _optional_. defaults to `terragrunt.hcl`. the files to search
-   **exclusion**: _optional_. defaults to `terragrunt/parameters`. a json list of modules that are not considered dependencies

### how to test

Requires the installation of `local-action`(https://github.com/github/local-action). Once it's installed, check the values you want to set in the `.env` file and run the following:

```
yarn install
local-action run .github/actions/terragrunt-graph . .github/actions/terragrunt-graph/.env
```

### how to build

```
yarn install
yarn package
```
