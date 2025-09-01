# lefthook - Git Hooks Repository

This repository provides pre-configured git hooks using [lefthook](https://github.com/evilmartians/lefthook). It contains standardized linting and validation configurations that can be imported into any project.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Installing Lefthook and Dependencies
- **Prerequisites**: Go 1.19+, Docker, Node.js 20+
- Install lefthook: `go install github.com/evilmartians/lefthook@latest` -- takes ~30 seconds
- Add to PATH: `export PATH=$PATH:~/go/bin`
- Install lefthook hooks: `lefthook install` -- takes ~0.02 seconds. NEVER CANCEL.
- Install Node.js dependencies: `npm install -g @commitlint/cli @commitlint/config-conventional markdownlint-cli` -- takes ~15 seconds. NEVER CANCEL.
- Install hadolint: `wget https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 && chmod +x hadolint-Linux-x86_64 && sudo mv hadolint-Linux-x86_64 /usr/local/bin/hadolint` -- takes ~5 seconds

### Running Hooks and Validation
- Test pre-commit hooks: `lefthook run pre-commit` -- takes 0.01-4 seconds depending on files
- **NEVER CANCEL**: Docker image pulls for linters can take 10-60 seconds on first run. Set timeout to 120+ seconds.
- Validate configuration: `lefthook validate` -- takes ~0.01 seconds
- Check lefthook version: `lefthook version`

### Hook Execution Times (First Run with Docker Pulls)
- **NEVER CANCEL**: shellcheck: ~45 seconds (Docker pull), then ~0.2-0.7 seconds per run
- **NEVER CANCEL**: markdownlint: ~20 seconds (Docker pull), then ~3.4 seconds per run  
- **NEVER CANCEL**: yamllint: ~15 seconds (Docker pull), then ~2.3 seconds per run
- **NEVER CANCEL**: hadolint: ~10 seconds (Docker pull), then ~0.7 seconds per run
- **NEVER CANCEL**: jsonlint: ~25 seconds (Docker pull), then ~3.2 seconds per run
- commitlint: ~0.8 seconds (uses local Node.js)
- license-checker: ~0.01 seconds (shell script)

### Repository Bootstrap Workflow
1. Clone repository: `git clone https://github.com/yacosta738/lefthook.git`
2. Install lefthook: `go install github.com/evilmartians/lefthook@latest`
3. Add to PATH: `export PATH=$PATH:~/go/bin`
4. Install hooks: `lefthook install`
5. Test: `lefthook run pre-commit` (should complete in ~0.01 seconds on clean repo)

## Validation

### Manual Testing Requirements
- ALWAYS test the complete git workflow after making changes to hook configurations
- Test with actual files that trigger each linter:
  - Create a .sh file with shell issues to test shellcheck: `echo 'echo $unquoted_var' > test.sh`
  - Create a .md file with formatting issues to test markdownlint: `echo '# Bad markdown\nSome content' > test.md`
  - Create a .yaml file with syntax issues to test yamllint: `echo 'test:  bad spacing' > test.yaml`
  - Create a Dockerfile with best practice violations to test hadolint: `echo 'FROM ubuntu:latest' > Dockerfile`
  - Create a .json file with syntax errors to test jsonlint: `echo '{"test": "missing comma" "error": true}' > test.json`
- Test commit message validation with both valid and invalid conventional commit formats:
  - Valid: `git commit -m "feat: add new feature"`
  - Invalid: `git commit -m "bad commit message"`
- Verify license header checking works with files missing the required header

### Complete Development Workflow Test
- Make a change to any hook configuration
- Create test files that should trigger the hooks
- Run `git add .` to stage files
- Run `git commit -m "test: validate hook changes"` to trigger all hooks
- Verify appropriate linting errors are caught and displayed
- Fix the test files and commit successfully
- **ALWAYS** ensure license headers are present: `# SPDX-FileCopyrightText: Copyright Yuniel Acosta, CU` and `# SPDX-License-Identifier: MIT`

## Common Tasks

### Available Hook Configurations
The repository provides these hook configurations in the `hooks/` directory:
- `commitlint/`: Validates commit messages follow conventional commits standard
- `shellcheck/`: Static analysis for shell scripts using Docker (koalaman/shellcheck:stable)
- `license-checker/`: Ensures license headers are present in source files  
- `markdown-lint/`: Lints markdown files using Docker (ghcr.io/igorshubovych/markdownlint-cli:latest)
- `yamllint/`: Validates YAML syntax and style using Docker (pipelinecomponents/yamllint:0.31.0)
- `jsonlint/`: Validates JSON syntax using Docker (pipelinecomponents/jsonlint:0.19.1) - not enabled by default
- `hadolint/`: Lints Dockerfiles using Docker (ghcr.io/hadolint/hadolint:latest) - not enabled by default
- `terraform/`: Formats, validates and tests Terraform code using Docker - not enabled by default

### Currently Enabled Hooks (in .lefthook.yaml)
- commitlint (commit-msg hook)
- shellcheck (pre-commit hook) 
- license-checker (pre-commit hook)
- markdown-lint (pre-commit hook)
- yamllint (pre-commit hook)

### Repository Structure
```
.
├── .lefthook.yaml              # Main lefthook configuration
├── .license-checker.txt        # License header template
├── .markdownlint.yaml         # Markdown linting rules
├── .yamllint.yaml            # YAML linting rules  
├── commitlint.config.mjs      # Commit message rules
├── hooks/                     # Hook configurations directory
│   ├── commitlint/           # Commit message validation
│   ├── shellcheck/           # Shell script linting
│   ├── license-checker/      # License header checking
│   ├── markdown-lint/        # Markdown linting
│   ├── yamllint/            # YAML linting
│   ├── jsonlint/            # JSON validation
│   ├── hadolint/            # Dockerfile linting
│   └── terraform/           # Terraform validation
└── docs/                     # Documentation
```

### Using Hooks in Other Projects
Create `.lefthook.yaml` in your project:
```yaml
remotes:
  - git_url: https://github.com/yacosta738/lefthook.git
    ref: v1.0.5
    configs:
      - hooks/commitlint/.lefthook.yaml
      - hooks/shellcheck/.lefthook.yaml
      - hooks/license-checker/.lefthook.yaml
      - hooks/markdown-lint/.lefthook.yaml
      - hooks/yamllint/.lefthook.yaml
```

Then run: `lefthook install`

### Build and Release Process
- No building required - this is a configuration repository
- Releases are managed via GitHub Actions using conventional commits (see .github/workflows/release.yml)
- Use semantic versioning tags (e.g., v1.0.5) for stable releases
- Release process uses goreleaser but is configured to skip builds

### License Header Management
- All files must include SPDX license headers
- Template is in `.license-checker.txt`
- License checker runs on every commit and will fail without proper headers
- Format: `# SPDX-FileCopyrightText: Copyright Yuniel Acosta, CU` and `# SPDX-License-Identifier: MIT`
- Files excluded from license check (see EXCLUDE_FILES_EXT): LICENSE, .md, .gitignore, .license-checker.txt, CODEOWNERS, .gitattributes, .editorconfig, .json, .lock, .toml, lock.yaml/.yml

### Troubleshooting
- If hooks fail to install: Check that lefthook is in PATH and run `lefthook install --force`
- If Docker-based linters fail: Ensure Docker is running and accessible
- If commit message validation fails: Use conventional commit format (type: description)
- For shellcheck errors: Add shebang line (#!/bin/bash) to shell scripts
- For license header errors: Add the required SPDX headers to the top of files

Fixes #8.