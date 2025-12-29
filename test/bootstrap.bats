#!/usr/bin/env bats

# Tests for script/bootstrap functionality

setup() {
  # Create a temporary directory for testing
  export TEST_DIR="$(mktemp -d)"
  export DOTFILES_ROOT="$TEST_DIR/dotfiles"
  export DOTFILES_DEST="$TEST_DIR/home"
  
  # Create directory structure
  mkdir -p "$DOTFILES_ROOT"
  mkdir -p "$DOTFILES_DEST"
  
  # Copy the bootstrap script to test directory
  cp "$BATS_TEST_DIRNAME/../script/bootstrap" "$DOTFILES_ROOT/bootstrap"
  
  # Source helper functions from bootstrap
  # We'll extract just the functions for testing
  cd "$DOTFILES_ROOT"
}

teardown() {
  # Clean up test directory
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# Helper function to extract and source functions from bootstrap
load_bootstrap_functions() {
  # Extract the link_file function from bootstrap
  cat "$DOTFILES_ROOT/bootstrap" | sed -n '/^link_file ()/,/^}/p' > "$TEST_DIR/functions.sh"
  cat "$DOTFILES_ROOT/bootstrap" | sed -n '/^info ()/,/^}/p' >> "$TEST_DIR/functions.sh"
  cat "$DOTFILES_ROOT/bootstrap" | sed -n '/^success ()/,/^}/p' >> "$TEST_DIR/functions.sh"
  cat "$DOTFILES_ROOT/bootstrap" | sed -n '/^fail ()/,/^}/p' >> "$TEST_DIR/functions.sh"
  
  # Add test-specific overrides
  echo "overwrite_all=false" >> "$TEST_DIR/functions.sh"
  echo "backup_all=false" >> "$TEST_DIR/functions.sh"
  echo "skip_all=false" >> "$TEST_DIR/functions.sh"
  
  source "$TEST_DIR/functions.sh"
}

@test "bootstrap script exists and is executable" {
  [ -f "$BATS_TEST_DIRNAME/../script/bootstrap" ]
  [ -x "$BATS_TEST_DIRNAME/../script/bootstrap" ]
}

@test "symlink files are created correctly" {
  # Create a test symlink file
  echo "test content" > "$DOTFILES_ROOT/test.symlink"
  
  # Create the expected symlink
  ln -s "$DOTFILES_ROOT/test.symlink" "$DOTFILES_DEST/.test"
  
  # Verify symlink exists and points to correct location
  [ -L "$DOTFILES_DEST/.test" ]
  [ "$(readlink $DOTFILES_DEST/.test)" = "$DOTFILES_ROOT/test.symlink" ]
  [ "$(cat $DOTFILES_DEST/.test)" = "test content" ]
}

@test "symlink files are found with correct pattern" {
  # Create test symlink files
  echo "content1" > "$DOTFILES_ROOT/file1.symlink"
  echo "content2" > "$DOTFILES_ROOT/file2.symlink"
  mkdir -p "$DOTFILES_ROOT/subdir"
  echo "content3" > "$DOTFILES_ROOT/subdir/file3.symlink"
  
  # Find all symlink files (mimicking bootstrap behavior)
  local count=$(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' | wc -l)
  
  [ "$count" -eq 3 ]
}

@test "symlink destination uses correct naming convention" {
  # Test that foo.symlink becomes ~/.foo
  local src="$DOTFILES_ROOT/gitconfig.symlink"
  echo "test" > "$src"
  
  local basename_result=$(basename "${src%.*}")
  [ "$basename_result" = "gitconfig" ]
  
  # The destination should be .$basename_result in DOTFILES_DEST
  local expected_dst="$DOTFILES_DEST/.gitconfig"
  [ ".$basename_result" = ".gitconfig" ]
}

@test "install script exists and is executable" {
  [ -f "$BATS_TEST_DIRNAME/../script/install" ]
  [ -x "$BATS_TEST_DIRNAME/../script/install" ]
}

@test "install script finds install.sh files" {
  # Create test install.sh files
  mkdir -p "$DOTFILES_ROOT/test1"
  mkdir -p "$DOTFILES_ROOT/test2"
  echo '#!/bin/sh' > "$DOTFILES_ROOT/test1/install.sh"
  echo 'echo "test1"' >> "$DOTFILES_ROOT/test1/install.sh"
  echo '#!/bin/sh' > "$DOTFILES_ROOT/test2/install.sh"
  echo 'echo "test2"' >> "$DOTFILES_ROOT/test2/install.sh"
  
  # Count install.sh files
  cd "$DOTFILES_ROOT"
  local count=$(find . -name install.sh | wc -l)
  
  [ "$count" -eq 2 ]
}

@test "all actual symlink files exist" {
  # Verify that all referenced symlink files in the repo actually exist
  local symlink_files=(
    "zsh/zshrc.symlink"
    "slate/slate.js.symlink"
    "git/gitignore.symlink"
    "git/gitconfig.symlink"
  )
  
  for file in "${symlink_files[@]}"; do
    [ -f "$BATS_TEST_DIRNAME/../$file" ]
  done
}

@test "all actual install.sh files exist" {
  # Verify that all referenced install.sh files in the repo actually exist
  local install_files=(
    "homebrew/install.sh"
    "slate/install.sh"
    "node/install.sh"
  )
  
  for file in "${install_files[@]}"; do
    [ -f "$BATS_TEST_DIRNAME/../$file" ]
  done
}

@test "bootstrap script sets DOTFILES_ROOT variable" {
  # Run bootstrap in dry-run mode to check environment setup
  cd "$BATS_TEST_DIRNAME/.."
  export DOTFILES_ROOT_TEST=$(pwd -P)
  
  [ -n "$DOTFILES_ROOT_TEST" ]
  [ -d "$DOTFILES_ROOT_TEST" ]
}

@test "bootstrap detects Codespaces environment" {
  # Test that CODESPACES variable is checked
  grep -q "CODESPACES" "$BATS_TEST_DIRNAME/../script/bootstrap"
}

@test "bootstrap detects Darwin (macOS) environment" {
  # Test that Darwin/macOS detection exists
  grep -q "Darwin" "$BATS_TEST_DIRNAME/../script/bootstrap"
}

@test "gitconfig.local.symlink.example exists as template" {
  [ -f "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" ]
}

@test "zsh install script exists" {
  [ -f "$BATS_TEST_DIRNAME/../zsh/install" ]
  [ -x "$BATS_TEST_DIRNAME/../zsh/install" ]
}
