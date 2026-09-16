# jamieshark dotfiles

These are dotfiles I use to personalize my terminal. They are arranged topically (see: https://jogendra.dev/i-do-dotfiles) so as to help separate what things to install for certain environments and machines.

## Installation

Bootstrap creates the dotfile links and installs missing dependencies. It will
not overwrite existing configs. Shell startup only loads existing configuration;
it does not download or install dependencies.

### macOS

```bash
git clone https://github.com/jamieshark/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

See [`script/README.md`](script/README.md) for bootstrap behavior, prerequisites,
side effects, testing, and network-monitor usage.

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
