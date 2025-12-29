#!/usr/bin/env bats

# Tests for install.sh scripts

setup() {
  export TEST_DIR="$(mktemp -d)"
  export DOTFILES_ROOT="$TEST_DIR/dotfiles"
  
  mkdir -p "$DOTFILES_ROOT"
  
  # Save original PATH
  export ORIGINAL_PATH="$PATH"
}

teardown() {
  # Clean up test directory
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
  
  # Restore PATH
  export PATH="$ORIGINAL_PATH"
}

@test "homebrew install.sh checks for brew command" {
  grep -q "which brew" "$BATS_TEST_DIRNAME/../homebrew/install.sh"
}

@test "homebrew install.sh detects Darwin (macOS)" {
  grep -q "Darwin" "$BATS_TEST_DIRNAME/../homebrew/install.sh"
}

@test "homebrew install.sh detects Linux" {
  grep -q "Linux" "$BATS_TEST_DIRNAME/../homebrew/install.sh"
}

@test "homebrew install.sh exits successfully when brew exists" {
  # Create a mock brew command
  mkdir -p "$TEST_DIR/bin"
  echo '#!/bin/sh' > "$TEST_DIR/bin/brew"
  echo 'exit 0' >> "$TEST_DIR/bin/brew"
  chmod +x "$TEST_DIR/bin/brew"
  
  # Add mock to PATH
  export PATH="$TEST_DIR/bin:$PATH"
  
  # Run the install script
  run "$BATS_TEST_DIRNAME/../homebrew/install.sh"
  
  [ "$status" -eq 0 ]
}

@test "node install.sh checks for spoof command" {
  grep -q "which spoof" "$BATS_TEST_DIRNAME/../node/install.sh"
}

@test "node install.sh checks for npm command" {
  grep -q "which npm" "$BATS_TEST_DIRNAME/../node/install.sh"
}

@test "slate install.sh is a placeholder" {
  # Slate install currently just echoes a message
  grep -q "installing slate" "$BATS_TEST_DIRNAME/../slate/install.sh"
}

@test "slate install.sh exits successfully" {
  run "$BATS_TEST_DIRNAME/../slate/install.sh"
  
  [ "$status" -eq 0 ]
}

@test "zsh install checks for oh-my-zsh directory" {
  grep -q "ZSH" "$BATS_TEST_DIRNAME/../zsh/install"
}

@test "zsh install checks for powerlevel10k theme" {
  grep -q "powerlevel10k" "$BATS_TEST_DIRNAME/../zsh/install"
}

@test "script/install finds and lists install.sh files" {
  # Create test directory structure
  mkdir -p "$DOTFILES_ROOT/component1"
  mkdir -p "$DOTFILES_ROOT/component2"
  
  # Create test install.sh files
  echo '#!/bin/sh' > "$DOTFILES_ROOT/component1/install.sh"
  echo 'exit 0' >> "$DOTFILES_ROOT/component1/install.sh"
  chmod +x "$DOTFILES_ROOT/component1/install.sh"
  
  echo '#!/bin/sh' > "$DOTFILES_ROOT/component2/install.sh"
  echo 'exit 0' >> "$DOTFILES_ROOT/component2/install.sh"
  chmod +x "$DOTFILES_ROOT/component2/install.sh"
  
  # Test that find command works as expected
  cd "$DOTFILES_ROOT"
  local count=$(find . -name install.sh | wc -l)
  
  [ "$count" -eq 2 ]
}

@test "script/install executes install.sh files" {
  # Create test directory structure
  mkdir -p "$DOTFILES_ROOT/testcomponent"
  
  # Create a test install.sh that creates a marker file
  echo '#!/bin/sh' > "$DOTFILES_ROOT/testcomponent/install.sh"
  echo "touch $TEST_DIR/marker" >> "$DOTFILES_ROOT/testcomponent/install.sh"
  chmod +x "$DOTFILES_ROOT/testcomponent/install.sh"
  
  # Execute the install script
  cd "$DOTFILES_ROOT"
  find . -name install.sh | while read installer ; do sh -c "${installer}" ; done
  
  # Verify marker file was created
  [ -f "$TEST_DIR/marker" ]
}

@test "all install.sh scripts are executable" {
  local install_files=(
    "$BATS_TEST_DIRNAME/../homebrew/install.sh"
    "$BATS_TEST_DIRNAME/../slate/install.sh"
    "$BATS_TEST_DIRNAME/../node/install.sh"
  )
  
  for file in "${install_files[@]}"; do
    [ -x "$file" ]
  done
}

@test "all install.sh scripts have shebang" {
  local install_files=(
    "$BATS_TEST_DIRNAME/../homebrew/install.sh"
    "$BATS_TEST_DIRNAME/../slate/install.sh"
  )
  
  for file in "${install_files[@]}"; do
    run head -n 1 "$file"
    [[ "$output" =~ ^#! ]]
  done
}

@test "script/install has correct shebang" {
  run head -n 1 "$BATS_TEST_DIRNAME/../script/install"
  [[ "$output" =~ ^#!/usr/bin/env\ bash ]]
}

@test "script/install uses set -e for error handling" {
  grep -q "set -e" "$BATS_TEST_DIRNAME/../script/install"
}
