### Using the Action

How to declare it:

```
- uses: gravicore/github-actions/.github/actions/veracode-scan@main
  with:
    appname: "My Application" # required
    stage: prd # required
    vid: ${{ secrets.VERACODE_API_ID }} # required
    vkey: ${{ secrets.VERACODE_API_KEY }} # required
    publish: true # optional, default true
```

**IMPORTANT!!:** `.github/setup.yml` is required for this action to run, see the following sections.

How to use with **Python**

```
# .github/setup.yml
veracode:
  python:
    source-dir: python # optional
    ignore-dirs: layers # optional, comma separated, supports multiline
    ignore-files: | # optional, comma separated, supports multiline
      easter.py,
      isoparser.py
    ignore-patterns: "*test*.py" # optional, comma separated, supports multiline
    dependency-file: # optional, array of dependency files to create Pipfile.lock for upload
      - requirements-1.txt
      - requirements-2.txt
```

How to use with **Java**

```
# .github/setup.yml
veracode:
  java:
    source-dir: java # optional
    java-version: 17 # optional, defaults to 18
    build-command: mvn # required, supports multiline
      clean package -f java
    ignore-patterns: "*test*.jar" # optional, comma separated, supports multiline
    uber-jar: true # optional, uploads just a single file with all classes and dependencies, defaults to false
```

How to use with **React**

```
# .github/setup.yml
veracode:
  react:
    source-dir: react # optional
    node-version: 17 # optional, defaults to 18
```

How to use with **.NET**

```
# .github/setup.yml
veracode:
  dotnet:
    source-dir: dotnet # optional
    dotnet-version: 8.0 # optional, defaults to 8.0
    build-type: sln # required
    publish-type: sln # required, one of sln, csproj
```

How to use with **Java**, **Python** and **React**

```
veracode:
  java:
    java-version: 16
    params...
  python:
    ignore-dirs: layers
    params...
  react:
    node-version: 16
    params...
  dotnet:
    dotnet-version: 8.0
    params...
```
