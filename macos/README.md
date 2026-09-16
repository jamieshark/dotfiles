# macOS defaults

`set-defaults.sh` applies the macOS preferences used by this repository.
`script/bootstrap` runs it automatically on macOS, or it can be run directly:

```bash
./macos/set-defaults.sh
```

The script configures:

- key repeat instead of press-and-hold;
- Finder list view, visible `~/Library`, and desktop drive visibility;
- the bottom-left hot corner for the screen saver; and
- Safari favorites and developer settings.

Most preferences use `defaults`; `chflags` unhides `~/Library`. Some changes
may require restarting the affected application or signing out before they
appear.

The related assertions are in `test/preferences.bats`.
