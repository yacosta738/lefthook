# commitlint hook

This hook uses [commitlint](https://commitlint.js.org/) to check if commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. The configuration is managed via Lefthook and the `commitlint.config.mjs` file at the project root.

## How to Use It

Add the commitlint hook to your Lefthook configuration:

```yaml
# .lefthook.yaml
remotes:
  - git_url: git@github.com:yacosta738/lefthook
    ref: [tag]
    configs:
      # Lint commit messages using commitlint and the conventional commits standard
      - hooks/commitlint/.lefthook.yaml
```

This will automatically run commitlint on every commit message to ensure it follows the conventional commit format.

## Configuration

Commitlint is configured in the `commitlint.config.mjs` file at the project root. You can customize rules and extends as needed. See the [commitlint documentation](https://commitlint.js.org/#/reference-configuration) for more details.

For more information on the commit message guidelines, see the [CONTRIBUTING.md](../../../docs/CONTRIBUTING.md) file (Updating Code section).
