#!/usr/bin/env bats

setup() {
  export DOTFILES_ROOT="$BATS_TEST_DIRNAME/.."
  export VSCODE_SETTINGS="$DOTFILES_ROOT/vscode/settings.json"
}

@test "VS Code settings are valid JSON" {
  python3 -m json.tool "$VSCODE_SETTINGS" >/dev/null
}

@test "VS Code settings do not retain stale extension preferences" {
  run grep -E \
    'github\.copilot\.editor\.enableAutoCompletions|gitlens\.showWelcomeOnInstall|markdownlint\.ignore|ruby\.rubocop\.autocorrectOnSave|vsintellicode\.modify\.editor\.suggestSelection' \
    "$VSCODE_SETTINGS"

  [ "$status" -eq 1 ]
}

@test "VS Code accessibility support is not forced off" {
  run grep -F '"editor.accessibilitySupport": "off"' "$VSCODE_SETTINGS"

  [ "$status" -eq 1 ]
}

@test "VS Code terminal defaults match supported platforms" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["terminal.integrated.defaultProfile.linux"] == "zsh"
assert settings["terminal.integrated.defaultProfile.osx"] == "zsh"
assert "terminal.integrated.defaultProfile.windows" not in settings
PY
}
