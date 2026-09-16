# Dotfiles Tests

This directory contains unit tests for the dotfiles installation scripts.

## Testing Framework

The tests use [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core), a TAP-compliant testing framework for Bash scripts.

## Running Tests

To run all tests:

```bash
./script/test
```

The test script will automatically install BATS if it's not already present.

## Test Files

- **bootstrap.bats** - Tests for the `script/bootstrap` functionality
  - Verifies symlink creation and naming conventions
  - Tests environment detection (Codespaces, macOS)
  - Validates all expected dotfiles exist
  
- **install.bats** - Tests for `script/install` and component installers
  - Verifies explicit, path-safe installer execution
  - Tests individual component installers (homebrew, node, zsh)
  - Validates script executability and error handling
- **shell.bats** - Tests shell startup configuration
  - Validates directory-only, duplicate-free PATH entries
  - Verifies platform-specific Homebrew and alias loading
  - Confirms startup performs no setup or network commands
  - Confirms NVM is loaded only when first used
  - Confirms missing optional runtimes do not cause startup errors
- **monitor-network-test** - Tests network threat detection and privacy behavior
  - Verifies vendor lookup uses a local OUI database
  - Verifies default execution makes no vendor API request
  - Verifies missing local vendor data is explicit and non-failing
- **vscode.bats** - Tests the shared VS Code settings baseline
  - Validates JSON syntax and platform terminal defaults
  - Rejects known stale extension settings
  - Ensures accessibility support is not forced off
  - Preserves warnings for unused ESLint disable directives
  - Verifies ESLint fixes run on save
  - Keeps `SERVICEOWNERS` out of Markdownlint validation
  - Verifies GitLens onboarding is skipped
  - Verifies Ruby LSP formats Ruby with RuboCop on save

## What the Tests Verify

### Bootstrap Script Tests
- ✅ Bootstrap script exists and is executable
- ✅ Symlinks are created correctly from `*.symlink` files
- ✅ Symlink naming convention (e.g., `foo.symlink` → `~/.foo`)
- ✅ Environment detection (Codespaces vs macOS)
- ✅ All expected symlink files exist in the repository
- ✅ Global Git config includes safely generated machine-local identity and credentials

### Install Script Tests
- ✅ Install script runs every declared `install.sh` file in order
- ✅ Install scripts are executable
- ✅ Homebrew installer checks for brew and detects OS
- ✅ Node installer preserves NVM or verifies its pinned official installer
- ✅ Node installer provisions a default Node LTS only when needed
- ✅ Zsh installer checks for oh-my-zsh and powerlevel10k
- ✅ Zsh startup remains configuration-only
- ✅ Error handling with `set -e`

## Adding New Tests

When adding new dotfiles or install scripts:

1. Add tests to verify the new files exist
2. Test any new installation logic
3. Ensure install.sh scripts are executable
4. Run `./script/test` to verify all tests pass

## Test Isolation

Tests run in isolated temporary directories to avoid affecting the actual system or repository. Each test:
- Creates a temporary test directory
- Sets up necessary environment variables
- Runs the test in isolation
- Cleans up after itself

## Continuous Integration

These tests are automatically run on every push and pull request via GitHub Actions. See [.github/workflows/test.yml](../.github/workflows/test.yml) for the CI configuration.

You can also run the tests locally before pushing to catch issues early.
