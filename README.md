# jamieshark dotfiles
 
These are dotfiles I use to personalize my terminal. They are arranged topically (see: https://jogendra.dev/i-do-dotfiles) so as to help separate what things to install for certain environments and machines.

## Installation

### For GitHub Codespaces
The installation script will automatically:
1. Install zsh (if not already installed)
2. Install Meslo Nerd Font for p10k glyphs
3. Install oh-my-zsh and powerlevel10k theme
4. Symlink zsh configuration files
5. Set zsh as the default shell

Run the following:
```bash
# Dotfiles are automatically cloned to /workspaces/.codespaces/.persistedshare/dotfiles
cd /workspaces/.codespaces/.persistedshare/dotfiles
script/bootstrap

# After installation, restart your terminal or run:
exec zsh
```

### For macOS
Run the following:
```zsh
git clone https://github.com/jamieshark/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```
This will symlink the appropriate files in .dotfiles to your home directory. Everything is configured and tweaked within ~/.dotfiles and changes are reflected immediately once updated profiles are reloaded.

## Testing
To ensure the dotfiles are installing correctly and prevent regressions:
```zsh
cd ~/.dotfiles
./script/test
```

See [test/README.md](test/README.md) for more information about the test suite.

## Features
- **zsh** with oh-my-zsh framework
- **powerlevel10k** theme with custom configuration
- **Meslo Nerd Font** for proper glyph rendering
- Custom aliases and environment settings
- Auto-completion and syntax highlighting plugins

# Other inspiration
https://dotfiles.github.io/inspiration/

- [ ] https://github.com/holman/dotfiles
- [ ] https://github.com/cheshire137/dotfiles
- [ ] https://github.com/kenyonj/dotfiles
- [ ] https://github.com/paulmillr/dotfiles
- [ ] https://github.com/skwp/dotfiles
- [ ] https://github.com/mathiasbynens/dotfiles
- [ ] https://github.com/webpro/dotfiles
- [ ] https://github.com/twpayne/dotfiles
