#!/usr/bin/env bash

set -euo pipefail

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
zsh_custom="${ZSH_CUSTOM:-$ZSH/custom}"

if [[ ! -d "$ZSH" ]]; then
  echo "Installing oh-my-zsh..."
  KEEP_ZSHRC=yes RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -d "$zsh_custom/themes/powerlevel10k" ]]; then
  echo "Installing powerlevel10k..."
  git clone --depth 1 https://github.com/romkatv/powerlevel10k.git \
    "$zsh_custom/themes/powerlevel10k"
fi

for plugin in zsh-completions zsh-syntax-highlighting zsh-autosuggestions; do
  if [[ ! -d "$zsh_custom/plugins/$plugin" ]]; then
    echo "Installing $plugin..."
    git clone --depth 1 "https://github.com/zsh-users/$plugin.git" \
      "$zsh_custom/plugins/$plugin"
  fi
done
