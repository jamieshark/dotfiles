# Zsh

`zshrc.symlink` loads the shell configuration without installing software.
Dependency setup belongs to `zsh/install.sh`, which is called by
`script/bootstrap`.

The installer adds missing:

- Oh My Zsh;
- Powerlevel10k;
- `zsh-completions`;
- `zsh-syntax-highlighting`; and
- `zsh-autosuggestions`.

The shell configuration loads platform-aware paths, aliases, environment
variables, the declared plugins, Powerlevel10k, and optional runtime
configuration. Missing optional runtimes remain quiet.

In Codespaces, bootstrap also installs Zsh and MesloLGS NF fonts when needed,
links `~/.zshrc` and `~/.p10k.zsh`, and may set Zsh as the default shell.

Restart the terminal or run `exec zsh` after initial setup.

See `test/shell.bats` for shell startup coverage.
