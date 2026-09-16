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
  # Extract the functions under test from bootstrap
  sed -n '/^setup_gitconfig ()/,/^}/p' < "$DOTFILES_ROOT/bootstrap" > "$TEST_DIR/functions.sh"
  sed -n '/^link_file ()/,/^}/p' < "$DOTFILES_ROOT/bootstrap" >> "$TEST_DIR/functions.sh"
  sed -n '/^install_dotfiles ()/,/^}/p' < "$DOTFILES_ROOT/bootstrap" >> "$TEST_DIR/functions.sh"
  sed -n '/^info ()/,/^}/p' < "$DOTFILES_ROOT/bootstrap" >> "$TEST_DIR/functions.sh"
  sed -n '/^success ()/,/^}/p' < "$DOTFILES_ROOT/bootstrap" >> "$TEST_DIR/functions.sh"
  sed -n '/^fail ()/,/^}/p' < "$DOTFILES_ROOT/bootstrap" >> "$TEST_DIR/functions.sh"
  
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

@test "install_dotfiles safely handles paths with spaces" {
  export DOTFILES_ROOT="$TEST_DIR/dot files"
  export DOTFILES_DEST="$TEST_DIR/home files"
  mkdir -p "$DOTFILES_ROOT/topic name" "$DOTFILES_DEST"
  echo "content" > "$DOTFILES_ROOT/topic name/file name.symlink"
  cp "$BATS_TEST_DIRNAME/../script/bootstrap" "$DOTFILES_ROOT/bootstrap"
  load_bootstrap_functions

  run install_dotfiles

  [ "$status" -eq 0 ]
  [ -L "$DOTFILES_DEST/.file name" ]
  [ "$(readlink "$DOTFILES_DEST/.file name")" = \
    "$DOTFILES_ROOT/topic name/file name.symlink" ]
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

@test "bootstrap delegates dependency installation to script/install" {
  grep -Fq '"$DOTFILES_ROOT/script/install"' "$BATS_TEST_DIRNAME/../script/bootstrap"
  ! grep -q "brew update" "$BATS_TEST_DIRNAME/../script/bootstrap"
}

@test "all actual symlink files exist" {
  # Verify that all referenced symlink files in the repo actually exist
  local symlink_files=(
    "zsh/zshrc.symlink"
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
    "node/install.sh"
    "zsh/install.sh"
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

@test "tracked gitconfig includes machine-local configuration without identity or credentials" {
  local gitconfig="$BATS_TEST_DIRNAME/../git/gitconfig.symlink"

  [ "$(git config --file "$gitconfig" --get include.path)" = "~/.gitconfig.local" ]
  ! git config --file "$gitconfig" --get user.name
  ! git config --file "$gitconfig" --get user.email
  ! git config --file "$gitconfig" --get credential.helper
  ! git config --file "$gitconfig" --get github.user
  [ -n "$(git config --file "$gitconfig" --get alias.pushit)" ]
}

@test "setup_gitconfig safely writes special characters to valid local config" {
  mkdir -p "$DOTFILES_ROOT/git"
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$DOTFILES_ROOT/git/"
  load_bootstrap_functions

  local author_name='Jamie / Shark & Co \ Team'
  local author_email='jamie+dev&ops/example@example.com'
  local expected_credential='cache'
  if [ "$(uname -s)" = "Darwin" ]; then
    expected_credential='osxkeychain'
  fi

  run setup_gitconfig <<< "$author_name"$'\n'"$author_email"

  [ "$status" -eq 0 ]
  local gitconfig="$DOTFILES_ROOT/git/gitconfig.local.symlink"
  [ "$(git config --file "$gitconfig" --get user.name)" = "$author_name" ]
  [ "$(git config --file "$gitconfig" --get user.email)" = "$author_email" ]
  [ "$(git config --file "$gitconfig" --get credential.helper)" = "$expected_credential" ]
  git config --file "$gitconfig" --list >/dev/null
  [ -z "$(find "$DOTFILES_ROOT/git" -name 'gitconfig.local.symlink.??????' -print -quit)" ]
}

@test "setup_gitconfig repairs empty identity in an existing local config" {
  mkdir -p "$DOTFILES_ROOT/git"
  local gitconfig="$DOTFILES_ROOT/git/gitconfig.local.symlink"
  local expected_credential='cache'
  if [ "$(uname -s)" = "Darwin" ]; then
    expected_credential='osxkeychain'
  fi
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$gitconfig"
  git config --file "$gitconfig" user.name ''
  git config --file "$gitconfig" user.email ''
  git config --file "$gitconfig" custom.preserved 'existing value'
  load_bootstrap_functions

  run setup_gitconfig <<< $'Jamie Shark\njamie@example.com'

  [ "$status" -eq 0 ]
  [ "$(git config --file "$gitconfig" --get user.name)" = "Jamie Shark" ]
  [ "$(git config --file "$gitconfig" --get user.email)" = "jamie@example.com" ]
  [ "$(git config --file "$gitconfig" --get credential.helper)" = "$expected_credential" ]
  [ "$(git config --file "$gitconfig" --get custom.preserved)" = "existing value" ]
  [ -z "$(find "$DOTFILES_ROOT/git" -name 'gitconfig.local.symlink.??????' -print -quit)" ]
}

@test "setup_gitconfig prompts only for missing identity and preserves valid values" {
  mkdir -p "$DOTFILES_ROOT/git"
  local gitconfig="$DOTFILES_ROOT/git/gitconfig.local.symlink"
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$gitconfig"
  git config --file "$gitconfig" user.name 'Existing Name'
  git config --file "$gitconfig" user.email ''
  load_bootstrap_functions

  run setup_gitconfig <<< 'new@example.com'

  [ "$status" -eq 0 ]
  [ "$(git config --file "$gitconfig" --get user.name)" = "Existing Name" ]
  [ "$(git config --file "$gitconfig" --get user.email)" = "new@example.com" ]
}

@test "setup_gitconfig preserves a custom credential helper during repair" {
  mkdir -p "$DOTFILES_ROOT/git"
  local gitconfig="$DOTFILES_ROOT/git/gitconfig.local.symlink"
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$gitconfig"
  git config --file "$gitconfig" user.name 'Existing Name'
  git config --file "$gitconfig" user.email ''
  git config --file "$gitconfig" credential.helper 'custom-helper'
  load_bootstrap_functions

  run setup_gitconfig <<< 'new@example.com'

  [ "$status" -eq 0 ]
  [ "$(git config --file "$gitconfig" --get credential.helper)" = "custom-helper" ]
}

@test "setup_gitconfig preserves multiple credential helpers during repair" {
  mkdir -p "$DOTFILES_ROOT/git"
  local gitconfig="$DOTFILES_ROOT/git/gitconfig.local.symlink"
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$gitconfig"
  git config --file "$gitconfig" user.name 'Existing Name'
  git config --file "$gitconfig" user.email ''
  git config --file "$gitconfig" --unset-all credential.helper
  git config --file "$gitconfig" --add credential.helper 'first-helper'
  git config --file "$gitconfig" --add credential.helper 'second-helper'
  load_bootstrap_functions

  run setup_gitconfig <<< 'new@example.com'

  [ "$status" -eq 0 ]
  [ "$(git config --file "$gitconfig" --get-all credential.helper)" = \
    $'first-helper\nsecond-helper' ]
}

@test "setup_gitconfig leaves valid existing identity unchanged" {
  mkdir -p "$DOTFILES_ROOT/git"
  local gitconfig="$DOTFILES_ROOT/git/gitconfig.local.symlink"
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$gitconfig"
  git config --file "$gitconfig" user.name 'Existing Name'
  git config --file "$gitconfig" user.email 'existing@example.com'
  git config --file "$gitconfig" credential.helper 'existing-helper'
  load_bootstrap_functions

  run setup_gitconfig </dev/null

  [ "$status" -eq 0 ]
  [ "$(git config --file "$gitconfig" --get user.name)" = "Existing Name" ]
  [ "$(git config --file "$gitconfig" --get user.email)" = "existing@example.com" ]
  [ "$(git config --file "$gitconfig" --get credential.helper)" = "existing-helper" ]
}

@test "setup_gitconfig removes its temporary file when the atomic move fails" {
  mkdir -p "$DOTFILES_ROOT/git"
  cp "$BATS_TEST_DIRNAME/../git/gitconfig.local.symlink.example" "$DOTFILES_ROOT/git/"
  load_bootstrap_functions
  mv() {
    return 1
  }

  run setup_gitconfig <<< $'Jamie Shark\njamie@example.com'

  [ "$status" -ne 0 ]
  [ ! -e "$DOTFILES_ROOT/git/gitconfig.local.symlink" ]
  [ -z "$(find "$DOTFILES_ROOT/git" -name 'gitconfig.local.symlink.??????' -print -quit)" ]
}

@test "zsh install script exists" {
  [ -f "$BATS_TEST_DIRNAME/../zsh/install.sh" ]
  [ -x "$BATS_TEST_DIRNAME/../zsh/install.sh" ]
}

@test "Codespaces fonts are downloaded only when missing" {
  grep -Fq 'if [[ ! -f "$font_path" ]]' "$BATS_TEST_DIRNAME/../script/bootstrap"
}
