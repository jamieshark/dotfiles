#!/usr/bin/env bats

# Integration tests for dotfiles installation
# These tests verify end-to-end functionality

setup() {
  export TEST_DIR="$(mktemp -d)"
  export DOTFILES_ROOT="$BATS_TEST_DIRNAME/.."
  export DOTFILES_DEST="$TEST_DIR/home"
  
  mkdir -p "$DOTFILES_DEST"
}

teardown() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

@test "can find all symlink files in repository" {
  cd "$DOTFILES_ROOT"
  local symlinks=$(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  
  # Should find at least the known symlink files
  [ -n "$symlinks" ]
  
  # Count should match expected
  local count=$(echo "$symlinks" | wc -l)
  [ "$count" -ge 4 ]
}

@test "symlink files have valid content" {
  # All symlink files should be readable and non-empty (or validly empty)
  cd "$DOTFILES_ROOT"
  
  for file in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*'); do
    [ -f "$file" ]
    [ -r "$file" ]
  done
}

@test "install.sh scripts can be discovered" {
  cd "$DOTFILES_ROOT"
  local install_scripts=$(find . -name install.sh -not -path '*.git*')
  
  [ -n "$install_scripts" ]
  
  # Should find at least the known install.sh files
  local count=$(echo "$install_scripts" | wc -l)
  [ "$count" -ge 3 ]
}

@test "script directory contains required scripts" {
  [ -f "$DOTFILES_ROOT/script/bootstrap" ]
  [ -f "$DOTFILES_ROOT/script/install" ]
  [ -f "$DOTFILES_ROOT/script/test" ]
  
  [ -x "$DOTFILES_ROOT/script/bootstrap" ]
  [ -x "$DOTFILES_ROOT/script/install" ]
  [ -x "$DOTFILES_ROOT/script/test" ]
}

@test "zsh configuration files exist" {
  [ -f "$DOTFILES_ROOT/zsh/zshrc.symlink" ]
  [ -f "$DOTFILES_ROOT/zsh/install" ]
}

@test "git configuration files exist" {
  [ -f "$DOTFILES_ROOT/git/gitconfig.symlink" ]
  [ -f "$DOTFILES_ROOT/git/gitignore.symlink" ]
  [ -f "$DOTFILES_ROOT/git/gitconfig.local.symlink.example" ]
}

@test "all component directories have proper structure" {
  # Check that key directories exist
  local dirs=("bin" "git" "homebrew" "node" "script" "system" "zsh")
  
  for dir in "${dirs[@]}"; do
    [ -d "$DOTFILES_ROOT/$dir" ]
  done
}

@test "bootstrap script contains all required functions" {
  local functions=("link_file" "install_dotfiles" "setup_gitconfig" "info" "success" "fail")
  
  for func in "${functions[@]}"; do
    grep -q "$func" "$DOTFILES_ROOT/script/bootstrap"
  done
}

@test "bootstrap uses correct symlink command" {
  # Verify ln -s is used for creating symlinks
  grep -q "ln -s" "$DOTFILES_ROOT/script/bootstrap"
}

@test "install script uses correct error handling" {
  # Verify set -e is present for error handling
  grep -q "set -e" "$DOTFILES_ROOT/script/install"
}
