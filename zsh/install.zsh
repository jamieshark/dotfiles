#!/bin/sh
#
# ZSH
#
# Installs oh-my-zsh, some plugins, and themes

zshrc() {
  if [ ! -d $ZSH ]
  then
    # oh-my-zsh install
    echo "==========================================================="
    echo "             cloning oh-my-zsh                             "
    echo "-----------------------------------------------------------"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  echo "==========================================================="
  echo "             cloning zsh-autosuggestions                   "
  echo "-----------------------------------------------------------"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  echo "==========================================================="
  echo "             cloning zsh-completions                   "
  echo "-----------------------------------------------------------"
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
  echo "==========================================================="
  echo "             cloning zsh-syntax-highlighting               "
  echo "-----------------------------------------------------------"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  echo "==========================================================="
  echo "             cloning powerlevel10k theme               "
  echo "-----------------------------------------------------------"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
}

zshrc
