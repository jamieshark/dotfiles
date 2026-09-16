# Script utilities

The `script/` directory contains the repository's maintained entry points for
installing, testing, and inspecting a local network. Run them from a trusted
clone of this repository.

| Script | Purpose |
| --- | --- |
| [`bootstrap`](#bootstrap) | Configure the dotfiles on macOS or in GitHub Codespaces. |
| [`install`](#install) | Run the Homebrew, Node.js, and Zsh component installers. |
| [`test`](#test) | Install BATS locally when needed and run the full test suite. |
| [`monitor-network`](#monitor-network) | Inspect a macOS network and record warnings or alerts. |

## `bootstrap`

`./script/bootstrap` is the top-level setup command.

On macOS it:

- prompts for missing Git author identity;
- links repository `*.symlink` files into `$HOME`;
- applies the settings in `macos/set-defaults.sh`; and
- runs `script/install`.

When a destination already exists, the script asks whether to skip it,
overwrite it, or move it to a sibling `.backup` path. Review each prompt:
overwrite removes the existing destination before creating the symlink.

In GitHub Codespaces it installs Zsh when missing, downloads the MesloLGS NF
font variants, installs the Zsh components, replaces `~/.zshrc` and
`~/.p10k.zsh` with repository symlinks, and may use `sudo chsh` to make Zsh the
default shell. Restart the terminal or run `exec zsh` afterward.

**Prerequisites:** Bash and Git. macOS setup also expects the standard macOS
command-line utilities and network access for missing dependencies. Codespaces
setup requires `sudo`, `apt-get`, `curl`, and `fc-cache`.

**Testing:** `test/bootstrap.bats` exercises symlink handling, platform
detection, delegation to `script/install`, and local Git configuration.
`test/integration.bats` covers the integrated setup behavior. Run everything
with `./script/test`.

## `install`

`./script/install` runs these component installers in order:

1. `homebrew/install.sh`
2. `node/install.sh`
3. `zsh/install.sh`

It accepts no options and stops at the first failed installer. It is safe to
rerun: existing Homebrew, NVM, a default Node.js version, Oh My Zsh,
Powerlevel10k, and declared Zsh plugins are preserved.

Missing components cause network downloads. Homebrew uses its supported
installer; NVM uses the pinned installer whose SHA-256 is verified before
execution; Node installs the current LTS when NVM has no default; and Zsh
components are cloned into the configured Oh My Zsh directories.

**Prerequisites:** Bash, `curl`, Git, and either `shasum` or `sha256sum`.
Homebrew installation supports macOS and Linux.

**Testing:** `test/install.bats` verifies installer order, path handling,
idempotent checks, and NVM checksum enforcement. Run everything with
`./script/test`.

## `test`

`./script/test` runs all `test/*.bats` suites and then
`test/monitor-network-test`.

If `test/libs/bats-core/bin/bats` is absent, the script clones BATS into
`test/libs/bats-core` before running tests. That first run therefore requires
Git and network access. Tests use temporary directories and command mocks to
avoid changing the user's dotfiles or scanning the active network.

**Prerequisites:** Bash and Git. Individual suites may expect platform tools;
CI installs Zsh before invoking the runner.

## `monitor-network`

`./script/monitor-network` is a macOS-oriented diagnostic tool. It discovers
the active interface and can report network details, enumerate devices, scan
ports, summarize connections, check ARP/DNS/DHCP state, capture a short traffic
sample, and inspect public remote IPs with reverse DNS.

Treat results as prompts for investigation, not proof of compromise. Several
checks use simple heuristics, and network equipment may block or alter scans.
Only run scans on networks and devices you own or are authorized to inspect.

### Commands and options

```text
./script/monitor-network
./script/monitor-network --section NAME
./script/monitor-network --inspect IP
./script/monitor-network --baseline
./script/monitor-network --watch
./script/monitor-network --interval SECONDS --watch
./script/monitor-network --help
```

- With no options, all sections run once.
- `--section NAME` runs one of `info`, `devices`, `ports`, `connections`,
  `arp`, `dns`, `dhcp`, `traffic`, or `malicious`.
- `--inspect IP` performs reverse-DNS and mDNS lookup plus an Nmap service and
  OS scan of one device.
- `--baseline` saves the current device scan as the known-good baseline.
- `--watch` runs the dashboard repeatedly; `--interval SECONDS` changes its
  default 60-second refresh interval.
- `--help` prints the built-in usage summary.

### macOS and Homebrew requirements

The implementation depends on macOS networking commands including `route`,
`ipconfig`, `ifconfig`, `networksetup`, and `scutil`. Install the required scan
tools with:

```bash
brew install nmap arp-scan
```

The traffic section uses `tcpdump`, which ships with macOS. Other checks use
standard tools such as `arp`, `lsof`, `dig`, `dns-sd`, and `curl`.

### `sudo` use

The script invokes `sudo` for operations that need elevated packet or scan
access:

- `arp-scan` device discovery;
- Nmap SYN, WAN reachability, DHCP discovery, and device inspection scans; and
- the 10-second `tcpdump` capture and termination of that capture.

Running all sections or watch mode may therefore prompt for an administrator
password. Sections that do not invoke those operations can run without
elevation.

### State and side effects

Each monitoring run creates `~/.config/monitor-network` when needed. The
script uses these files:

| File | Purpose |
| --- | --- |
| `known_devices.txt` | Device IP/MAC baseline written by `--baseline`. |
| `monitor.log` | Timestamped warnings and alerts appended across runs. |
| `allowed_ports.txt` | Gateway ports automatically recorded after a suspicious LAN port is verified as closed or filtered from the public internet. |

`--baseline` replaces the saved device baseline. Delete or edit these files
manually when you want to reset their history. The traffic section also creates
a temporary capture under `/tmp` and removes it after analysis.

### Privacy and network activity

MAC vendor lookup is local-only. The script reads an OUI database supplied by
Homebrew's `arp-scan`, a local Wireshark installation, or another readable file
selected with:

```bash
MONITOR_NETWORK_OUI_DATABASE=/path/to/local/oui-database \
  ./script/monitor-network --section devices
```

MAC addresses and other local device identifiers are not sent to a vendor API.
If no readable local database is found, the vendor is reported as unavailable
without a remote fallback.

Other checks intentionally create network traffic:

- the `info` section requests the public IP from `https://api.ipify.org`;
- the `ports` section requests the public IP from `https://ifconfig.me`, scans
  the gateway, and may scan that public IP;
- `devices`, `dhcp`, `traffic`, and `--inspect` probe or capture activity on the
  local network;
- `dns` resolves `example.com` through the active resolver; and
- `malicious` and `--inspect` perform reverse-DNS lookups for observed or
  selected IP addresses.

The `malicious` section does not upload addresses to a threat-intelligence API;
its current checks use local connection data and DNS lookups.

### Testing

Run the focused monitor tests:

```bash
./test/monitor-network-test
```

Run the full repository suite:

```bash
./script/test
```

The focused suite mocks external commands and verifies threat-detection
heuristics, baseline behavior, logging, and local-only vendor lookup without
scanning the active network.
