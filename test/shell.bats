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

@test "Homebrew shell environment is skipped outside macOS" {
  mkdir -p "$TEST_DIR/bin"
  cat > "$TEST_DIR/bin/uname" <<'EOF'
#!/bin/sh
echo Linux
EOF
  cat > "$TEST_DIR/bin/brew" <<'EOF'
#!/bin/sh
echo 'exit 42'
EOF
  chmod +x "$TEST_DIR/bin/uname" "$TEST_DIR/bin/brew"

  run env PATH="$TEST_DIR/bin:/usr/bin" /bin/zsh -c 'source "$1"' \
    zsh "$REPO_ROOT/homebrew/path.zsh"

  [ "$status" -eq 0 ]
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
