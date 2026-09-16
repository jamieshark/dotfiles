# VS Code

`settings.json` is a user-settings baseline; bootstrap does not install it.
Merge the file into VS Code user settings, then use Settings Sync to share it
with trusted Codespaces.

## GitHub Codespaces

```bash
cd /workspaces/.codespaces/.persistedshare/dotfiles
script/bootstrap
exec zsh
```

The configured language formatters and themes expect these extensions where
their features are used:

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

`github.codespaces.showPerformanceExplorer` is Codespaces-specific and requires
the `GitHub.codespaces` desktop extension. The macOS and Linux terminal
profiles expect Zsh; Windows uses VS Code's detected PowerShell profile.

Copilot settings use VS Code's bundled support and require an eligible signed-in
account. Ruby LSP is excluded from Settings Sync so it can remain
environment-specific.

Configuration checks are in `test/vscode.bats`.
