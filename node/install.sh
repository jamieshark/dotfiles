#!/usr/bin/env bash

set -euo pipefail

brew_command="$(command -v brew || true)"
for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -z "$brew_command" && -x "$brew_candidate" ]]; then
    brew_command="$brew_candidate"
  fi
done
unset brew_candidate

if [[ -z "$brew_command" ]]; then
  echo "Homebrew is required to install NVM." >&2
  exit 1
fi

if ! "$brew_command" list --formula nvm >/dev/null 2>&1; then
  echo "Installing NVM..."
  "$brew_command" install nvm
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
mkdir -p "$NVM_DIR"
source "$("$brew_command" --prefix nvm)/nvm.sh"

if ! nvm version default >/dev/null 2>&1; then
  echo "Installing the current Node.js LTS..."
  nvm install --lts
  nvm alias default 'lts/*'
fi
