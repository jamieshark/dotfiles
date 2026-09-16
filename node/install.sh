#!/usr/bin/env bash

set -eo pipefail

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
nvm_script="$NVM_DIR/nvm.sh"

if [[ ! -s "$nvm_script" ]]; then
  nvm_version="v0.40.7"
  nvm_installer_url="https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh"
  nvm_installer_sha256="066ce4eaf4d78eaa6410433bc9ba58faaba646157cbbed6109153e6c24c5f8a5"
  nvm_installer="$(mktemp)"
  trap 'rm -f "$nvm_installer"' EXIT

  echo "Installing NVM $nvm_version..."
  curl --fail --silent --show-error --location \
    "$nvm_installer_url" \
    --output "$nvm_installer"

  if command -v shasum >/dev/null 2>&1; then
    nvm_installer_actual_sha256="$(shasum -a 256 "$nvm_installer")"
  elif command -v sha256sum >/dev/null 2>&1; then
    nvm_installer_actual_sha256="$(sha256sum "$nvm_installer")"
  else
    echo "A SHA-256 checksum utility is required to install NVM." >&2
    exit 1
  fi
  nvm_installer_actual_sha256="${nvm_installer_actual_sha256%% *}"

  if [[ "$nvm_installer_actual_sha256" != "$nvm_installer_sha256" ]]; then
    echo "NVM installer checksum verification failed." >&2
    exit 1
  fi

  PROFILE=/dev/null NVM_DIR="$NVM_DIR" bash "$nvm_installer"
fi

if [[ ! -s "$nvm_script" ]]; then
  echo "NVM installed, but its initialization script was not found." >&2
  exit 1
fi

source "$nvm_script"

if ! command -v nvm >/dev/null 2>&1; then
  echo "NVM failed to initialize." >&2
  exit 1
fi

if ! nvm version default >/dev/null 2>&1; then
  echo "Installing the current Node.js LTS..."
  nvm install --lts
  nvm alias default 'lts/*'
fi
