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

@test "VS Code reports unused ESLint disable directives" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["eslint.options"]["overrideConfig"]["linterOptions"]["reportUnusedDisableDirectives"] == "warn"
PY
}

@test "VS Code applies ESLint fixes on save" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["eslint.format.enable"] is True
assert settings["editor.codeActionsOnSave"]["source.fixAll.eslint"] == "explicit"
PY
}

@test "VS Code excludes SERVICEOWNERS from Markdownlint" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["files.associations"]["SERVICEOWNERS"] == "plaintext"
PY
}

@test "VS Code skips GitLens onboarding" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["gitlens.advanced.skipOnboarding"] is True
PY
}

@test "VS Code formats Ruby with RuboCop through Ruby LSP" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["[ruby]"]["editor.defaultFormatter"] == "Shopify.ruby-lsp"
assert settings["rubyLsp.formatter"] == "rubocop"
assert settings["editor.formatOnSave"] is True
PY
}

@test "VS Code terminal defaults match supported platforms" {
  python3 - "$VSCODE_SETTINGS" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as settings_file:
    settings = json.load(settings_file)

assert settings["terminal.integrated.defaultProfile.linux"] == "zsh"
assert settings["terminal.integrated.defaultProfile.osx"] == "zsh"
assert settings["terminal.integrated.defaultProfile.windows"] == "PowerShell"
assert settings["terminal.integrated.profiles.windows"]["PowerShell"]["source"] == "PowerShell"
PY
}
