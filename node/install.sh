#!/usr/bin/env bash

set -euo pipefail

if ! command -v spoof >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  npm install --global spoof
fi
