# Bash fallback

The `bash/` directory preserves Git completion and prompt helpers for
environments where Zsh is unavailable.

Source them from a Bash configuration as needed:

```bash
source "$HOME/.dotfiles/bash/git-completion.bash"
source "$HOME/.dotfiles/bash/git-prompt.sh"
```

`git-completion.bash` provides Git tab completion. `git-prompt.sh` provides
`__git_ps1`, which can be included in `PS1`; configuration examples are in the
script header.
