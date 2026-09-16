# Git configuration

`gitconfig.symlink` contains shared Git behavior, including aliases, colors,
pull/push defaults, Git LFS filters, and an include for `~/.gitconfig.local`.

Machine-specific identity and credentials belong in the ignored
`gitconfig.local.symlink`. Bootstrap creates or repairs that file, prompts only
for missing name or email values, and preserves valid custom entries.

Check the effective identity and its source with:

```bash
git config --global --includes --show-origin \
  --get-regexp '^user\.(name|email)$'
```

To repair values manually:

```bash
git config --file ~/.gitconfig.local user.name "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

When bootstrap creates or repairs the local configuration, it defaults to the
`osxkeychain` credential helper on macOS and Git's credential cache elsewhere.
Existing valid or custom helper settings are preserved.
