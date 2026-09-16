#!/usr/bin/env bash
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  exit 0
fi

case "$(uname -s)" in
  Darwin|Linux)
    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ;;
  *)
    echo "Homebrew is not supported on this operating system." >&2
    exit 1
    ;;
esac

exit 0
