### Using the Action

How to declare it:

```
- uses: gravicore/github-actions/.github/actions/sonar-scan@main
  with:
    branch: "my-branch" # optional, use it only if your sonar installation supports branches or the action will throw an error
    github_comments: false # optional, used to enable scan results comments
    github_token: "gh_abc" # optional. it is required when pr_comments is set to true
    maven_token: ${{ secrets.MAVEN_TOKEN }}$ # optional, used only if your repository builds java and requires private libraries
    module: "test" # optional, in case you need to support more than one project in the same repository
    project: "my-project" # optional, defaults to the repository name
    sonar_coverage: "80" # optional, minimum global coverage to enable warnings
    sonar_gate: "Sonar%20way" # optional, the quality gate to use
    sonar_host: "https://mysonar" # required
    sonar_token: ${{ secrets.SONAR_TOKEN }} # required
    stage: dev # optional, used only to decide which git sha should be used
```

**IMPORTANT!!:** `.github/setup.yml` is required for this action to run, see the following sections.

How to use with **Python**

```
# .github/setup.yml
sonar:
  python:
    path: python # optional, defaults to python
    version: "3.9" # optional, defaults to 3.9
    command: "python -m ..." # optional, will look for multiple modules under "path" and test each one in isolation
    pattern: "test_*.py" # optional, defaults to test_*.py
    ignore-errors: false # optional, defaults to false - used to ignore test failures during coverage, will implicate in data loss, so keep the default if possible

```

How to use with **Java**

```
# .github/setup.yml
sonar:
  java:
    path: java # optional, defaults to java
    version: "18" # optional, defaults to 18
    command: "mvn ..." # optional, defaults to 'mvn clean verify -f java'
    pattern: "**/*Test.*" # optional, defaults to **/*Test.*
    ignore-errors: false # optional, defaults to false - used to ignore test failures during coverage, will implicate in data loss, so keep the default if possible

```

How to use with **Java (GraalVM)**

To use GraalVM instead of standard Java, prefix the version with `graalvm-`:

```
# .github/setup.yml
sonar:
  java:
    path: java # optional, defaults to java
    version: "graalvm-22" # Uses Oracle GraalVM with Java 22
    command: "mvn ..." # optional, defaults to 'mvn clean verify -f java'
    pattern: "**/*Test.*" # optional, defaults to **/*Test.*
    ignore-errors: false # optional, defaults to false

```

| Version Format | Distribution | Java Version |
|----------------|--------------|--------------|
| `version: "22"` | Temurin | 22 |
| `version: "graalvm-22"` | GraalVM | 22 |

How to use with **JavaScript**

```
# .github/setup.yml
sonar:
  javascript:
    path: src # optional, defaults to javascript
    version: "20" # optional, defaults to 20
    command: "yarn install && ..." # optional, defaults to 'yarn test'
    pattern: "**/*.test.*" # optional, defaults to **/*.test.*
    ignore-errors: false # optional, defaults to false - used to ignore test failures during coverage, will implicate in data loss, so keep the default if possible

```

How to use with **Python**, **Java** and **JavaScript**

```
# .github/setup.yml
sonar:
  python:
    ...
  java:
    ...
  javascript:
    ...
```
