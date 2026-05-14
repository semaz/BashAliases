# Bash aliases

A collection of useful bash/zsh aliases and helper functions for the terminal.

## Install

```
git clone git@github.com:semaz/BashAliases.git ~/BashAliases
```

```
cd ~/BashAliases && bash install.sh
```

## Structure

```
autoload.sh                  # entry point — sources all scripts/*.sh
install.sh                   # adds autoload.sh to ~/.zshrc / ~/.bashrc
scripts/
  1.term.sh                  # PATH, colors, PS1, EDITOR, helper functions
  2.functions.sh             # aliases: ls, grep, ps, php/composer
  3.filesystem.sh            # aliases: find, extract, cd shortcuts, disk utils
  4.ssh.sh                   # ssh wrapper — injects sshrc.sh on remote host
  5.network.sh               # network utils
  6.platform.macos.sh        # macOS only
  6.platform.linux.sh        # Linux only
sshrc.sh.dist                # template for sshrc.sh
```

## Aliases

### Universal

#### Navigation

| Alias | Command |
|-------|---------|
| `~` | `cd ~` |
| `..` / `cd..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |
| `cdl` | `cd` + `ll` |

#### Files

| Alias | Command |
|-------|---------|
| `f` | find file by name in current dir |
| `ft` | find files containing text |
| `extract` | extract any archive (tar, zip, gz, bz2, 7z, rar…) |
| `fixEol` | strip Windows line endings (`\r`) |
| `tf` | `tail -f` |
| `numFiles` | count files in current dir |
| `size` | folder size (`du -sh`) |
| `sizer` | recursive folder sizes |
| `disks` | available disk space |
| `dirspace` | sizes of all subdirs, sorted |

#### Listing

| Alias | Command |
|-------|---------|
| `ls` | `ls` with color |
| `ll` | `ls -lha` |
| `l.` | list hidden files only |
| `lsd` | list directories only |

#### Search

| Alias | Command |
|-------|---------|
| `grep` / `egrep` / `fgrep` | grep with color |
| `hg` | `history | grep` |

#### Processes

| Alias | Command |
|-------|---------|
| `ps2` | `ps -ef` filtered by keyword |
| `psg` | `ps aux` filtered by keyword |
| `psme` | processes of current user |

#### PHP / Composer

| Alias | Command |
|-------|---------|
| `cmp` | `composer` |
| `cmpin` | `composer install` |
| `cmpup` | `composer update -W` |
| `cmpdu` | `composer dump-autoload` |
| `sf` | `php bin/console` |
| `cept` | `php vendor/bin/codecept` |
| `phinx` | `php vendor/bin/phinx` |

#### Network

| Alias | Command |
|-------|---------|
| `myip` | print external IP |
| `edithosts` | edit `/etc/hosts` in `$EDITOR` |
| `trace` | `mtr` (if installed) |

#### Other

| Alias | Command |
|-------|---------|
| `c` | `clear` |
| `g` | `git` |

---

### macOS only

| Alias | Command |
|-------|---------|
| `edit` | open file in TextEdit |
| `flushDNS` | flush DNS cache |
| `finderHiddenShow` | show hidden files in Finder |
| `finderHiddenHide` | hide hidden files in Finder |
| `rmDS` | remove all `.DS_Store` recursively |
| `rmZoneIdentifier` | remove all `Zone.Identifier` files recursively |

---

### Linux only

| Alias | Command |
|-------|---------|
| `apt` | `sudo apt` |
| `aptall` | update + upgrade + autoremove |
| `openPorts` | show all open ports (`ss -tulnp`) |

---

## SSH config injection

`4.ssh.sh` wraps the `ssh` command: on connect it injects `sshrc.sh` into the
remote session via base64. Create `sshrc.sh` manually or copy the template:

```
cp sshrc.sh.dist sshrc.sh
```

The file is gitignored — customize it freely.

`sshrc.sh` receives `$SSHRC_HOST` (the target hostname) so you can `cd` to the
right directory automatically per host using `_cd_by_host`.

### @include directives

`sshrc.sh` supports `# @include <path>` directives to pull in local script files
before injection. Paths are relative to the project root:

```bash
# @include scripts/1.term.sh
# @include scripts/2.functions.sh
# @include scripts/3.filesystem.sh
```

`_sshrc_resolve()` in `4.ssh.sh` expands includes recursively, strips comments
and blank lines, then base64-encodes the result for SSH transport. This keeps
`sshrc.sh` concise while reusing the same helper functions available locally.

---

## motd

`motd()` is defined in `scripts/1.term.sh` and displays a system info panel on
SSH login. Call it at the end of `sshrc.sh` to show it on connect.

**What it shows:**

| Row | Source |
|-----|--------|
| Hostname + user + OS | `hostname`, `id -un`, `/etc/os-release` |
| Date / time | `date` |
| Uptime | `/proc/uptime` → formatted as `3d 4h 12m` |
| Load average | `/proc/loadavg` — each value colored green/yellow/red relative to CPU count |
| Memory / Swap | `free -m` — progress bar + percentage + human size |
| Disk | `df /` — progress bar + percentage + free/total |
| IP address | `hostname -I` |
| Logged-in users | `who` — unique count + names |
| Systemd services | `systemctl list-units --failed` |

Progress bars use `▓` (filled) and `░` (empty). Color thresholds: green < 75%, yellow 75–89%, red ≥ 90%. At red threshold the label and percentage are also highlighted.

The separator line width adapts to the terminal width via `tput cols`.
