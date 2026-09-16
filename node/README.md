# Node.js and NVM

`install.sh` installs a pinned NVM release from its official installer and
verifies its SHA-256 before execution. If NVM has no default Node.js version,
it installs the current LTS and sets it as the default.

The installer is invoked by `script/install` and is safe to rerun.

Shell startup does not eagerly initialize NVM. The Zsh configuration loads NVM
when Node tooling is first used, reducing startup work while preserving access
to `node`, `npm`, `npx`, and `nvm`.

Installer and lazy-loading behavior are covered by `test/install.bats` and
`test/shell.bats`.
