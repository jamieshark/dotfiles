#!/usr/bin/env bats

# Tests for component installers

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
  grep -q "command -v brew" "$BATS_TEST_DIRNAME/../homebrew/install.sh"
}

@test "homebrew install.sh detects Darwin (macOS)" {
  grep -q "Darwin" "$BATS_TEST_DIRNAME/../homebrew/install.sh"
}

@test "homebrew install.sh detects Linux" {
  grep -q "Linux" "$BATS_TEST_DIRNAME/../homebrew/install.sh"
}

@test "homebrew install.sh uses the supported installer" {
  grep -Fq '/bin/bash -c' "$BATS_TEST_DIRNAME/../homebrew/install.sh"
  grep -Fq 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' \
    "$BATS_TEST_DIRNAME/../homebrew/install.sh"
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

@test "node install.sh uses Homebrew to provision NVM" {
  grep -Fq 'list --formula nvm' "$BATS_TEST_DIRNAME/../node/install.sh"
  grep -Fq 'install nvm' "$BATS_TEST_DIRNAME/../node/install.sh"
  ! grep -q "spoof" "$BATS_TEST_DIRNAME/../node/install.sh"
}

@test "node install.sh skips setup when NVM and a default Node version exist" {
  local prefix="$TEST_DIR/nvm-prefix"
  mkdir -p "$prefix" "$TEST_DIR/bin"
  cat > "$prefix/nvm.sh" <<EOF
nvm() {
  if [[ "\$1" == "version" && "\$2" == "default" ]]; then
    return 0
  fi
  echo "\$*" >> "$TEST_DIR/nvm-commands"
}
EOF
  cat > "$TEST_DIR/bin/brew" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "list" ]]; then
  exit 0
fi
if [[ "\$1" == "--prefix" ]]; then
  echo "$prefix"
  exit 0
fi
echo "\$*" >> "$TEST_DIR/brew-commands"
EOF
  chmod +x "$TEST_DIR/bin/brew"

  run env HOME="$TEST_DIR/home" PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    "$BATS_TEST_DIRNAME/../node/install.sh"

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ ! -e "$TEST_DIR/brew-commands" ]
  [ ! -e "$TEST_DIR/nvm-commands" ]
}

@test "node install.sh installs NVM and a default Node LTS when missing" {
  local prefix="$TEST_DIR/nvm-prefix"
  mkdir -p "$prefix" "$TEST_DIR/bin"
  cat > "$prefix/nvm.sh" <<EOF
nvm() {
  if [[ "\$1" == "version" && "\$2" == "default" ]]; then
    return 3
  fi
  echo "\$*" >> "$TEST_DIR/nvm-commands"
}
EOF
  cat > "$TEST_DIR/bin/brew" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "list" ]]; then
  exit 1
fi
if [[ "\$1" == "--prefix" ]]; then
  echo "$prefix"
  exit 0
fi
echo "\$*" >> "$TEST_DIR/brew-commands"
EOF
  chmod +x "$TEST_DIR/bin/brew"

  run env HOME="$TEST_DIR/home" PATH="$TEST_DIR/bin:/usr/bin:/bin" \
    "$BATS_TEST_DIRNAME/../node/install.sh"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Installing NVM..."* ]]
  [[ "$output" == *"Installing the current Node.js LTS..."* ]]
  [ "$(cat "$TEST_DIR/brew-commands")" = "install nvm" ]
  [ "$(cat "$TEST_DIR/nvm-commands")" = $'install --lts\nalias default lts/*' ]
}

@test "zsh install checks for oh-my-zsh directory" {
  grep -q "ZSH" "$BATS_TEST_DIRNAME/../zsh/install.sh"
}

@test "zsh install checks for powerlevel10k theme" {
  grep -q "powerlevel10k" "$BATS_TEST_DIRNAME/../zsh/install.sh"
}

@test "zsh install declares all custom plugins" {
  grep -q "zsh-completions" "$BATS_TEST_DIRNAME/../zsh/install.sh"
  grep -q "zsh-syntax-highlighting" "$BATS_TEST_DIRNAME/../zsh/install.sh"
  grep -q "zsh-autosuggestions" "$BATS_TEST_DIRNAME/../zsh/install.sh"
}

@test "zsh install performs no network work when dependencies exist" {
  local zsh_dir="$TEST_DIR/oh-my-zsh"
  local zsh_custom="$zsh_dir/custom"
  mkdir -p \
    "$zsh_custom/themes/powerlevel10k" \
    "$zsh_custom/plugins/zsh-completions" \
    "$zsh_custom/plugins/zsh-syntax-highlighting" \
    "$zsh_custom/plugins/zsh-autosuggestions" \
    "$TEST_DIR/bin"

  for command in curl git; do
    cat > "$TEST_DIR/bin/$command" <<EOF
#!/bin/sh
echo "$command" >> "$TEST_DIR/commands"
exit 99
EOF
    chmod +x "$TEST_DIR/bin/$command"
  done

  run env ZSH="$zsh_dir" ZSH_CUSTOM="$zsh_custom" \
    PATH="$TEST_DIR/bin:/usr/bin:/bin" "$BATS_TEST_DIRNAME/../zsh/install.sh"

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ ! -e "$TEST_DIR/commands" ]
}

@test "script/install executes declared installers from a path with spaces" {
  local root="$TEST_DIR/dot files"
  mkdir -p "$root/script" "$root/homebrew" "$root/node" "$root/zsh"
  cp "$BATS_TEST_DIRNAME/../script/install" "$root/script/install"

  for component in homebrew node zsh; do
    cat > "$root/$component/install.sh" <<EOF
#!/usr/bin/env bash
echo "$component" >> "$TEST_DIR/installers"
EOF
    chmod +x "$root/$component/install.sh"
  done

  run "$root/script/install"

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  [ "$(cat "$TEST_DIR/installers")" = $'homebrew\nnode\nzsh' ]
}

@test "all install.sh scripts are executable" {
  local install_files=(
    "$BATS_TEST_DIRNAME/../homebrew/install.sh"
    "$BATS_TEST_DIRNAME/../node/install.sh"
    "$BATS_TEST_DIRNAME/../zsh/install.sh"
  )
  
  for file in "${install_files[@]}"; do
    [ -x "$file" ]
  done
}

@test "all install.sh scripts have shebang" {
  local install_files=(
    "$BATS_TEST_DIRNAME/../homebrew/install.sh"
    "$BATS_TEST_DIRNAME/../node/install.sh"
    "$BATS_TEST_DIRNAME/../zsh/install.sh"
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
