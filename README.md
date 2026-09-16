# jamieshark dotfiles

Personal macOS and GitHub Codespaces configuration organized by topic.

## Installation

Bootstrap is explicit and safe to rerun. Shell startup only loads existing
configuration; it does not download or install dependencies.

### macOS

```bash
git clone https://github.com/jamieshark/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

### GitHub Codespaces

```bash
cd /workspaces/.codespaces/.persistedshare/dotfiles
script/bootstrap
exec zsh
```

See [`script/README.md`](script/README.md) for bootstrap behavior, prerequisites,
side effects, testing, and network-monitor usage.

## Topic guides

| Topic | Documentation |
| --- | --- |
| Scripts and setup | [`script/README.md`](script/README.md) |
| macOS defaults | [`macos/README.md`](macos/README.md) |
| Zsh and Codespaces | [`zsh/README.md`](zsh/README.md) |
| Bash fallback | [`bash/README.md`](bash/README.md) |
| Git configuration | [`git/README.md`](git/README.md) |
| Node.js and NVM | [`node/README.md`](node/README.md) |
| VS Code | [`vscode/README.md`](vscode/README.md) |
| Test suites | [`test/README.md`](test/README.md) |

## Highlights

- Zsh with Oh My Zsh, Powerlevel10k, completions, autosuggestions, and syntax
  highlighting
- Platform-aware paths for Apple Silicon, Intel macOS, and Linux
- Machine-local Git identity with shared aliases
- Idempotent Homebrew, NVM, Node.js LTS, and shell setup
- Curated macOS defaults and system-inspection aliases
- Local-first network device vendor lookup

## Inspiration

- <https://dotfiles.github.io/inspiration/>
- <https://github.com/holman/dotfiles>
- <https://github.com/cheshire137/dotfiles>
- <https://github.com/kenyonj/dotfiles>
- <https://github.com/paulmillr/dotfiles>
- <https://github.com/skwp/dotfiles>
- <https://github.com/mathiasbynens/dotfiles>
- <https://github.com/webpro/dotfiles>
- <https://github.com/twpayne/dotfiles>
