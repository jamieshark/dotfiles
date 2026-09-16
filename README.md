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

### VS Code

`vscode/settings.json` is a user-settings baseline; the bootstrap script does not install it. Merge it into VS Code user settings, then use Settings Sync to share it with trusted Codespaces.

The configured formatters and UI values expect these extensions where their languages or themes are used:

- `manuelpuyol.erb-linter`
- `golang.go`
- `esbenp.prettier-vscode`
- `stylelint.vscode-stylelint`
- `dbaeumer.vscode-eslint`
- `DavidAnson.vscode-markdownlint`
- `GitHub.vscode-pull-request-github`
- `eamodio.gitlens`
- `GitHub.github-vscode-theme`
- `PKief.material-icon-theme`
- `miguelsolorio.fluent-icons`

The `github.codespaces.showPerformanceExplorer` preference is Codespaces-only and requires the `GitHub.codespaces` desktop extension. Codespaces bootstrap installs zsh, so the Linux terminal default is valid there. The macOS default also expects zsh; Windows uses VS Code's detected default shell.

Copilot completion preferences use the support bundled with current VS Code and require a signed-in account with Copilot access. `Shopify.ruby-lsp` remains excluded from Settings Sync so Ruby tooling can be installed per environment when a project needs it.

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
- Curated navigation and macOS system-inspection aliases
- macOS keyboard, Finder, Dock, and Safari defaults
- Platform-aware shell configuration across Apple Silicon, Intel macOS, and Linux
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
