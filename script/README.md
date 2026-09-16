# Script utilities

The `script/` directory contains the maintained entry points for installing,
testing, and inspecting a local network. Run them from a trusted clone.

| Script | Purpose |
| --- | --- |
| [`bootstrap`](#bootstrap) | Configure the dotfiles on macOS or in GitHub Codespaces. |
| [`install`](#install) | Run the Homebrew, Node.js, and Zsh installers. |
| [`test`](#test) | Run the complete test suite. |
| [`monitor-network`](#monitor-network) | Inspect a macOS network and record warnings or alerts. |

## `bootstrap`

`./script/bootstrap` is the top-level setup command.

- **macOS:** prompts for missing Git identity, links `*.symlink` files, applies
  macOS defaults, and runs `script/install`.
- **Codespaces:** installs Zsh and fonts when missing, installs Zsh components,
  links the shell configuration, and may use `sudo chsh`.

Conflicting existing destinations prompt for skip, overwrite, or backup.
Overwrite removes the destination; backup moves it to a sibling `.backup` path.

**Requires:** Bash and Git. Codespaces also requires `sudo`, `apt-get`, `curl`,
and `fc-cache`.

**Tests:** `test/bootstrap.bats` and `test/integration.bats`.

## `install`

`./script/install` runs these idempotent component installers in order:

1. `homebrew/install.sh`
2. `node/install.sh`
3. `zsh/install.sh`

Missing components may be downloaded. NVM uses a pinned, checksum-verified
installer; Node installs the current LTS only when no default exists.

**Requires:** Bash, `curl`, Git, and `shasum` or `sha256sum`. Homebrew
installation supports macOS and Linux.

**Tests:** `test/install.bats`.

## `test`

`./script/test` runs every `test/*.bats` suite followed by
`test/monitor-network-test`.

If BATS is missing, the runner clones it into `test/libs/bats-core`. Tests use
temporary directories and command mocks to avoid changing user configuration
or scanning the active network.

**Requires:** Bash and Git. CI installs Zsh before running the suite.

## `monitor-network`

`./script/monitor-network` is a macOS-oriented diagnostic tool for network
details, device discovery, port and connection inspection, ARP/DNS/DHCP checks,
traffic sampling, and reverse-DNS checks.

Results are investigative signals, not proof of compromise. Only scan networks
and devices you own or are authorized to inspect.

### Commands and options

```text
./script/monitor-network
./script/monitor-network --section NAME
./script/monitor-network --inspect IP
./script/monitor-network --baseline
./script/monitor-network --watch [--interval SECONDS]
./script/monitor-network --help
```

- No options runs all sections once.
- `--section` accepts `info`, `devices`, `ports`, `connections`, `arp`, `dns`,
  `dhcp`, `traffic`, or `malicious`.
- `--inspect` performs name, service, port, and OS checks for one device.
- `--baseline` saves the current device list.
- `--watch` refreshes the dashboard every 60 seconds by default.

### macOS and Homebrew requirements

Install the required scanners with:

```bash
brew install nmap arp-scan
```

The script also uses standard macOS networking tools. `tcpdump` is optional and
ships with macOS.

### `sudo` use

`sudo` is required for ARP discovery, Nmap SYN/DHCP/device scans, and the
10-second `tcpdump` capture. Running all sections or watch mode may therefore
prompt for an administrator password.

### State and side effects

State is stored under `~/.config/monitor-network/`:

| File | Purpose |
| --- | --- |
| `known_devices.txt` | Device baseline written by `--baseline`. |
| `monitor.log` | Timestamped warnings and alerts. |
| `allowed_ports.txt` | Gateway ports verified as LAN-only. |

Delete or edit these files to reset their history. Traffic captures use a
temporary file under `/tmp` that is removed after analysis.

### Privacy and network activity

MAC vendor lookup is local-only. It uses an `arp-scan` or Wireshark OUI
database, or a local file selected with:

```bash
MONITOR_NETWORK_OUI_DATABASE=/path/to/oui-database \
  ./script/monitor-network --section devices
```

MAC addresses and other local device identifiers are never sent to a vendor
API. Missing local data produces an unavailable vendor result with no remote
fallback.

Other checks intentionally access the network:

- `info` and `ports` request the public IP from `api.ipify.org` or `ifconfig.me`.
- `ports` scans the gateway and may run `sudo nmap` against the public IP when
  checking whether a suspicious gateway port is internet-accessible.
- `devices`, `dhcp`, `traffic`, and `--inspect` scan or capture local network
  activity.
- `dns`, `malicious`, and `--inspect` perform DNS lookups.

The `malicious` section does not upload IP addresses to a threat-intelligence
API.

### Testing

```bash
./test/monitor-network-test
./script/test
```

The focused suite mocks external commands, so it does not scan the active
network.
