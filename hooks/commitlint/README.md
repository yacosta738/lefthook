# commitlint hook

This hook uses [commitlint](https://commitlint.js.org/) to check if commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. The configuration is managed via Lefthook and supports both local and remote configuration setups.

## Quick Start

### Remote Configuration Setup

### ⚙️ For Project Teams

To use a remote commitlint configuration in your projects:

1. **Create your project's `.lefthook.yaml`**:

```yaml
# .lefthook.yaml
---
remotes:
  - git_url: https://github.com/yacosta738/lefthook.git
    ref: v1.0.5  # Use the latest stable version
    configs:
      - hooks/commitlint/.lefthook.yaml  # Name of your commitlint configuration
```

2. **Install required dependencies locally**:

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

3. **Install the hooks**:

```bash
npx lefthook install
```

4. **Copy the default commitlint configuration (if you don't have one)**:

```bash
# Option 1: Use the provided setup script
bash .git/info/lefthook-remotes/lefthook*/hooks/commitlint/setup-commitlint.sh

# Option 2: Copy manually
cp .git/info/lefthook-remotes/lefthook*/hooks/commitlint/commitlint.config.js ./commitlint.config.js

# Option 3: Create your own custom configuration
cat > commitlint.config.js << 'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'header-max-length': [2, 'always', 120],
    'body-max-line-length': [2, 'always', 220],
  },
};
EOF
```

### 🔄 Synchronizing Remote Configurations

Lefthook automatically checks for updates in remote configurations. To manually force an update:

```bash
npx lefthook install
```

## Local Configuration

For projects that prefer local configuration, create a `.lefthook.yaml` in your project root:

```yaml
# .lefthook.yaml
commit-msg:
  commands:
    "lint commit message":
      run: npx commitlint --edit {1}
```

And ensure you have a `commitlint.config.js` or `commitlint.config.mjs` file:

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'header-max-length': [2, 'always', 120],
    'body-max-line-length': [2, 'always', 220],
  },
};
```

## Remote Configuration Setup

### 🚀 For Repository Maintainers

If you want to set up your own remote configuration repository similar to this one:

1. **Create a dedicated configuration repository** (e.g., `my-org/lefthook-configs`)
2. **Create the commitlint configuration file** (`lefthook-commitlint.yml`):

```yaml
commit-msg:
  commands:
    "lint commit message":
      run: npx commitlint --edit {1}  # Uses {1} to capture the commit message file
```

3. **Include a standard commitlint config** (`commitlint.config.js`):

```javascript
module.exports = { extends: ['@commitlint/config-conventional'] };
```

### ⚙️ For Project Teams

To use a remote commitlint configuration in your projects:

1. **Create your project's `.lefthook.yaml`**:

```yaml
# .lefthook.yaml
---
remotes:
  - git_url: git@github.com:my-org/lefthook-configs.git  # Your config repository
    configs:
      - lefthook-commitlint.yml  # Name of your commitlint configuration
```

2. **Install required dependencies locally**:

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

3. **Install the hooks**:

```bash
npx lefthook install
```

### 🔄 Synchronizing Remote Configurations

Lefthook automatically checks for updates in remote configurations. To manually force an update:

```bash
npx lefthook install
```

## Configuration

This hook uses the `commitlint.config.js` file included in this directory for default configuration when used as a remote. The default configuration in this repository includes:

- Extends `@commitlint/config-conventional`
- Maximum header length: 120 characters
- Maximum body line length: 220 characters

You can customize rules as needed. See the [commitlint documentation](https://commitlint.js.org/#/reference-configuration) for more details.

## Testing Your Configuration

Verify that the commitlint integration works properly:

```bash
# This should pass
git commit -m "feat: add new feature"

# This should fail
git commit -m "invalid commit message"
```

## 💡 Benefits of Remote Configuration

- **Consistency**: All projects follow the same commit message rules
- **Centralized maintenance**: Update rules in one place, apply everywhere
- **Scalability**: Easy to add more hooks or modify configurations
- **Team alignment**: Ensures all team members use identical standards

## ⚠️ Troubleshooting

### Dependencies Not Found

Ensure commitlint is installed locally in each project:

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

### Configuration File Not Found

If you get an error about missing configuration, ensure you have a `commitlint.config.js` file in your project root. You can copy it from the remote:

```bash
# After running lefthook install, copy the config
cp .git/info/lefthook-remotes/lefthook*/hooks/commitlint/commitlint.config.js ./commitlint.config.js
```

### Git Worktrees Issues

If using Git worktrees, you might need to adjust the `GIT_DIR` environment variable:

```yaml
commit-msg:
  commands:
    "lint commit message":
      run: npx commitlint --edit {1}
      env:
        GIT_DIR: "{.git}"
```

### Remote Repository Access

Verify that your projects have proper permissions to clone the configuration repository.

## Example Project Structure

```
my-config-repo/
├── lefthook-commitlint.yml
└── commitlint.config.js

my-project/
├── .lefthook.yaml
├── package.json
└── node_modules/
    ├── @commitlint/cli/
    └── @commitlint/config-conventional/
```

## References

- [Commitlint Documentation](https://commitlint.js.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Lefthook Documentation](https://github.com/evilmartians/lefthook)