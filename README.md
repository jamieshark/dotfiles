# jamieshark dotfiles
 
These are dotfiles I use to personalize my terminal. They are arranged topically (see: https://jogendra.dev/i-do-dotfiles) so as to help separate what things to install for certain environments and machines.

## Installation

Installation is explicit: `script/bootstrap` creates the dotfile links and installs
missing dependencies. Opening or reloading zsh only loads configuration; it never
downloads, clones, or installs anything. Re-running bootstrap is safe and skips
dependencies that are already present.

### For GitHub Codespaces
The installation script will automatically:
1. Install zsh (if not already installed)
2. Install missing Meslo Nerd Font variants for p10k glyphs
3. Install missing oh-my-zsh, powerlevel10k, and zsh plugins
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

On macOS, bootstrap applies the repository's system preferences, installs Homebrew
with its supported installer when needed, and then runs each declared component
installer. Homebrew is discovered from Apple Silicon and Intel prefixes without
requiring shell-startup installation logic.

Bootstrap preserves an existing NVM installation or installs a pinned NVM
release from its verified official installer when missing. It provisions the
current Node.js LTS only when NVM has no default version, and Node tooling
remains lazy-loaded until first use.

Bootstrap prompts for any missing Git author name or email, then creates or
repairs the ignored `git/gitconfig.local.symlink` while preserving valid
identity values. New or repaired configuration uses the platform-appropriate
credential helper. The tracked global Git configuration includes this file as
`~/.gitconfig.local`, keeping machine-specific settings out of the repository.

### Bash fallback
If Zsh is unavailable, source `~/.dotfiles/bash/git-completion.bash` and `~/.dotfiles/bash/git-prompt.sh` from your Bash configuration. The completion script enables Git tab completion; call `__git_ps1` from `PS1` to show the current branch. The prompt script includes configuration examples in its header.

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
- `Shopify.ruby-lsp`
- `GitHub.github-vscode-theme`
- `PKief.material-icon-theme`
- `miguelsolorio.fluent-icons`

The `github.codespaces.showPerformanceExplorer` preference is Codespaces-only and requires the `GitHub.codespaces` desktop extension. Codespaces bootstrap installs zsh, so the Linux terminal default is valid there. The macOS default also expects zsh; Windows uses VS Code's detected PowerShell profile.

Copilot completion preferences use the support bundled with current VS Code and require a signed-in account with Copilot access. `Shopify.ruby-lsp` remains excluded from Settings Sync so it can be installed only in environments that work on Ruby; when installed, it formats Ruby with RuboCop on save.

## Testing
To ensure the dotfiles are installing correctly and prevent regressions:
```zsh
cd ~/.dotfiles
./script/test
```

See [test/README.md](test/README.md) for more information about the test suite.

## Network monitor privacy

`script/monitor-network` keeps device vendor lookup local. It reads the OUI database installed by `arp-scan` or Wireshark and never sends MAC addresses or other local device identifiers to a vendor API. If no supported local database is available, vendor names are reported as unavailable without a remote fallback. Set `MONITOR_NETWORK_OUI_DATABASE` to use another local database file.

## Features
- **zsh** with oh-my-zsh framework
- **powerlevel10k** theme with custom configuration
- **Meslo Nerd Font** for proper glyph rendering
- Curated navigation and macOS system-inspection aliases
- macOS keyboard, Finder, Dock, and Safari defaults
- Platform-aware shell configuration across Apple Silicon, Intel macOS, and Linux
- Git auto-completion through oh-my-zsh, plus syntax highlighting plugins
- Idempotent NVM and Node.js LTS setup with lazy shell initialization
- Optional Git completion and prompt fallback for Bash

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
