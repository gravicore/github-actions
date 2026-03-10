# Snyk SBOM Generator GitHub Action

This GitHub Action generates a **Software Bill of Materials (SBOM)** using the **Snyk CLI**. It supports multiple project ecosystems and produces a **CycloneDX JSON SBOM** by default.

The action is designed to standardize SBOM generation across repositories and can be reused in CI/CD pipelines for:

- Node.js
- Python
- Java (Maven)
- Java (Gradle)
- .NET

The generated SBOM can then be uploaded as a build artifact, attached to releases, or stored alongside deployment artifacts for compliance and supply-chain security.

---

# What This Action Does

This action performs the following steps:

1. Validates the specified language input.
2. Installs the required runtime environment (optional):
   - Node.js
   - Python
   - Java
   - .NET
3. Installs the **Snyk CLI**.
4. Authenticates using the `SNYK_TOKEN`.
5. Runs the **`snyk sbom`** command.
6. Outputs a **CycloneDX SBOM JSON file**.

The default SBOM format is:

```
cyclonedx1.6+json
```

The output file defaults to:

```
sbom.json
```

---

# Supported Languages

| Language Input | Supported Build Type |
|---|---|
| `node` | Node.js / npm / yarn |
| `python` | Python / pip |
| `maven` | Java Maven |
| `gradle` | Java Gradle |
| `dotnet` | .NET |

---

# Required Secrets

You must provide a **Snyk API token**.

```
SNYK_TOKEN
```

Create one in Snyk and add it to your repository or organization secrets.

---

# Basic Usage

If this action exists in the same repository as the workflow:

```yaml
- name: Generate SBOM
  uses: ./.github/actions/snyk-sbom
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    language: node
    all-projects: true
```

If calling the action **from another repository in the `gravicore` organization**:

```yaml
- name: Generate SBOM
  uses: gravicore/github-actions/.github/actions/snyk-sbom@main
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    language: node
    all-projects: true
```

---

# Inputs

| Input | Description | Required | Default |
|---|---|---|---|
| `language` | Project language | Yes | |
| `working-directory` | Directory containing the project | No | `.` |
| `output-file` | SBOM output filename | No | `sbom.json` |
| `format` | SBOM format | No | `cyclonedx1.6+json` |
| `all-projects` | Detect multiple manifests | No | `false` |
| `detection-depth` | Depth for manifest detection | No | |
| `extra-args` | Additional Snyk CLI arguments | No | |
| `snyk-version` | Snyk CLI version | No | `latest` |
| `setup-runtime` | Install runtime environment | No | `true` |
| `node-version` | Node version | No | `20` |
| `python-version` | Python version | No | `3.11` |
| `java-version` | Java version | No | `17` |
| `dotnet-version` | .NET SDK version | No | `8.0.x` |

---

# Outputs

| Output | Description |
|---|---|
| `sbom-file` | Path to generated SBOM |

---

# Example Workflows

## Node.js Example

```yaml
name: Node SBOM

on:
  workflow_dispatch:

jobs:
  sbom:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Generate Node SBOM
        uses: gravicore/github-actions/.github/actions/snyk-sbom@main
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          language: node
          all-projects: true
          output-file: sbom-node.json

      - uses: actions/upload-artifact@v4
        with:
          name: node-sbom
          path: sbom-node.json
```

---

## Python Example

```yaml
- name: Generate Python SBOM
  uses: gravicore/github-actions/.github/actions/snyk-sbom@main
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    language: python
    all-projects: true
    output-file: sbom-python.json
```

---

## Maven Example

```yaml
- name: Generate Maven SBOM
  uses: gravicore/github-actions/.github/actions/snyk-sbom@main
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    language: maven
    all-projects: true
    output-file: sbom-maven.json
```

---

## Gradle Example

```yaml
- name: Generate Gradle SBOM
  uses: gravicore/github-actions/.github/actions/snyk-sbom@main
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    language: gradle
    all-projects: true
    output-file: sbom-gradle.json
```

---

## .NET Example

```yaml
- name: Generate .NET SBOM
  uses: gravicore/github-actions/.github/actions/snyk-sbom@main
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
  with:
    language: dotnet
    all-projects: true
    output-file: sbom-dotnet.json
```

---

# Recommended CI/CD Placement

SBOM generation should run **after dependency resolution and before artifact publication**.

Typical pipeline structure:

```
checkout
install dependencies
build
tests
security scans
generate SBOM
publish artifact
deploy
```

This ensures the SBOM reflects the **final dependency graph used in the build**.

---

# Example Output

```
sbom.json
```

Example artifact structure:

```
build/
 ├── service.jar
 ├── sbom.json
 └── metadata.json
```

---

# Best Practices

- Generate **one SBOM per build**
- Store SBOMs alongside build artifacts
- Use **CycloneDX format** for compatibility with most security platforms
- Upload SBOMs to artifact storage or dependency tracking tools

---

# License

MIT