#!/usr/bin/env bats

setup() {
  export DOTFILES_ROOT="$BATS_TEST_DIRNAME/.."
}

@test "active Ruby and Node cleanup preferences remain configured" {
  grep -q 'rbenv init -' "$DOTFILES_ROOT/ruby/rbenv.zsh"
  grep -q 'alias rmNM=' "$DOTFILES_ROOT/zsh/aliases"
}

@test "key repeat preferences remain configured" {
  grep -q 'ApplePressAndHoldEnabled -bool false' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'KeyRepeat -int 1' "$DOTFILES_ROOT/macos/set-defaults.sh"
}

@test "Finder list and volume preferences remain configured" {
  grep -q 'FXPreferredViewStyle Nlsv' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'chflags nohidden ~/Library' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'ShowExternalHardDrivesOnDesktop -bool true' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'ShowRemovableMediaOnDesktop -bool true' "$DOTFILES_ROOT/macos/set-defaults.sh"
}

@test "bottom-left hot corner starts the screensaver" {
  grep -q 'wvous-bl-corner -int 5' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'wvous-bl-modifier -int 0' "$DOTFILES_ROOT/macos/set-defaults.sh"
}

@test "Safari favorites and developer preferences remain configured" {
  grep -q 'ShowFavoritesBar -bool false' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'IncludeDevelopMenu -bool true' "$DOTFILES_ROOT/macos/set-defaults.sh"
  grep -q 'WebKitDeveloperExtras -bool true' "$DOTFILES_ROOT/macos/set-defaults.sh"
}
