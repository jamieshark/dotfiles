#!/usr/bin/env bats

setup() {
  export REPO_ROOT="$BATS_TEST_DIRNAME/.."
  export TEST_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "PATH configuration keeps existing directories unique" {
  mkdir -p "$TEST_DIR/home/bin" "$TEST_DIR/zsh/bin"

  run env HOME="$TEST_DIR/home" ZSH="$TEST_DIR/zsh" \
    zsh -c 'PATH="$HOME/bin:/usr/bin:/usr/bin"; source "$1"; print -r -- "$PATH"' \
    zsh "$REPO_ROOT/system/_path.zsh"

  [ "$status" -eq 0 ]
  [ "${output%%:*}" = "$TEST_DIR/home/bin" ]
  [ "$(tr ':' '\n' <<< "$output" | sort | uniq -d)" = "" ]

  while IFS= read -r directory; do
    [ -d "$directory" ]
  done < <(tr ':' '\n' <<< "$output")
}

@test "PATH configuration supports Apple Silicon and Intel Homebrew" {
  grep -Fq "/opt/homebrew/bin" "$REPO_ROOT/system/_path.zsh"
  grep -Fq "/usr/local/bin" "$REPO_ROOT/system/_path.zsh"
}

@test "Homebrew shell environment loads on macOS from PATH" {
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/uname" <<'EOF'
#!/bin/sh
echo Darwin
EOF
  cat > "$TEST_DIR/bin/brew" <<'EOF'
#!/bin/sh
echo 'export HOMEBREW_TEST=loaded'
EOF
  chmod +x "$TEST_DIR/bin/uname" "$TEST_DIR/bin/brew"

  run env PATH="$TEST_DIR/bin:/usr/bin" /bin/zsh -c \
    'source "$1"; print -r -- "$HOMEBREW_TEST"' zsh "$REPO_ROOT/homebrew/path.zsh"

  [ "$status" -eq 0 ]
  [ "$output" = "loaded" ]
}

@test "Homebrew shell environment loads on Linux from PATH" {
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/uname" <<'EOF'
#!/bin/sh
echo Linux
EOF
  cat > "$TEST_DIR/bin/brew" <<'EOF'
#!/bin/sh
echo 'export HOMEBREW_TEST=loaded'
EOF
  chmod +x "$TEST_DIR/bin/uname" "$TEST_DIR/bin/brew"

  run env PATH="$TEST_DIR/bin:/usr/bin" /bin/zsh -c \
    'source "$1"; print -r -- "$HOMEBREW_TEST"' zsh "$REPO_ROOT/homebrew/path.zsh"

  [ "$status" -eq 0 ]
  [ "$output" = "loaded" ]
}

@test "macOS-only aliases are not exposed on Linux" {
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/uname" <<'EOF'
#!/bin/sh
echo Linux
EOF
  chmod +x "$TEST_DIR/bin/uname"

  run env PATH="$TEST_DIR/bin:/usr/bin:/bin" zsh -c \
    'source "$1"; alias f flushDNS ipInfo0 ipInfo1' \
    zsh "$REPO_ROOT/zsh/aliases"

  [ "$status" -ne 0 ]
  [[ "$output" != *"open -a Finder"* ]]
  [[ "$output" != *"dscacheutil"* ]]
}

@test "missing optional runtimes do not cause startup errors" {
  run env PATH="/usr/bin:/bin" VERBOSE= zsh -c \
    'source "$1"; source "$2"; source "$3"' \
    zsh \
    "$REPO_ROOT/node/path.zsh" \
    "$REPO_ROOT/python/path.zsh" \
    "$REPO_ROOT/ruby/rbenv.zsh"

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "zsh startup performs no setup or network commands" {
  mkdir -p "$TEST_DIR/home" "$TEST_DIR/zsh" "$TEST_DIR/bin"

  for command in curl git npm; do
    cat > "$TEST_DIR/bin/$command" <<EOF
#!/bin/sh
echo "$command" >> "$TEST_DIR/commands"
exit 99
EOF
    chmod +x "$TEST_DIR/bin/$command"
  done

  run env HOME="$TEST_DIR/home" ZSH="$TEST_DIR/zsh" VERBOSE= \
    PATH="$TEST_DIR/bin:/usr/bin:/bin" /bin/zsh -f -c 'source "$1"' \
    zsh "$REPO_ROOT/zsh/zshrc.symlink"

  [ "$status" -eq 0 ]
  [ ! -e "$TEST_DIR/commands" ]
}

@test "zsh startup lazily loads nvm" {
  grep -Fq 'load_nvm()' "$REPO_ROOT/zsh/zshrc.symlink"
  ! grep -Fq 'bash_completion' "$REPO_ROOT/zsh/zshrc.symlink"
}

@test "zsh plugin configuration has no installation side effects" {
  ! grep -Eq 'git clone|curl|npm install' "$REPO_ROOT/zsh/plugins"
}

@test "Git completion is provided by the oh-my-zsh git plugin" {
  grep -Eq '^[[:space:]]*git[[:space:]]*$' "$REPO_ROOT/zsh/plugins"
  grep -Fq 'source "$ZSH/oh-my-zsh.sh"' "$REPO_ROOT/zsh/zshrc.symlink"
}

@test "obsolete vendored Git shell scripts are absent" {
  [ ! -e "$REPO_ROOT/git/.git-prompt.sh" ]
  [ ! -e "$REPO_ROOT/git/completion.zsh" ]
}

@test "Git completion and prompt remain available as optional Bash fallbacks" {
  [ -f "$REPO_ROOT/bash/git-completion.bash" ]
  [ -f "$REPO_ROOT/bash/git-prompt.sh" ]
  grep -Fq '__git_complete git __git_main' "$REPO_ROOT/bash/git-completion.bash"
  grep -Fq '__git_ps1' "$REPO_ROOT/bash/git-prompt.sh"
}
