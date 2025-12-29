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
  
- **install.bats** - Tests for `script/install` and individual `install.sh` scripts
  - Verifies install.sh discovery mechanism
  - Tests individual component installers (homebrew, node, slate, zsh)
  - Validates script executability and error handling

## What the Tests Verify

### Bootstrap Script Tests
- ✅ Bootstrap script exists and is executable
- ✅ Symlinks are created correctly from `*.symlink` files
- ✅ Symlink naming convention (e.g., `foo.symlink` → `~/.foo`)
- ✅ Environment detection (Codespaces vs macOS)
- ✅ All expected symlink files exist in the repository

### Install Script Tests
- ✅ Install script finds all `install.sh` files
- ✅ Install scripts are executable
- ✅ Homebrew installer checks for brew and detects OS
- ✅ Node installer checks for npm and spoof
- ✅ Zsh installer checks for oh-my-zsh and powerlevel10k
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
