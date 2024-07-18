### Using the Action

How to declare it:

```
- uses: gravicore/github-actions/.github/actions/setup-java@main
  with:
    username: "github" # optional
    organization: "my-org" #required
    password: ${{ secrets.WRITE_PACKAGES_TOKEN }} # required
    version: 11 # optional
```

**Why we need to set the password to a PAT?** **Github** packages do not support App tokens, even with `write:packages` permissions. For more information, see:

- https://github.com/orgs/community/discussions/26920
- https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages

Ideally, we can start using this action to configure the `settings.xml` file and later when **Github** starts supporting this, switch to the temporary token via App.

The organization needs to configure a secret called `WRITE_PACKAGES_TOKEN` with, at least, the `write:packages` permission.
