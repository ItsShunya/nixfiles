# Building and deploying

Every host is built from the flake on the desktop (`shunya-dsktp`). The desktop applies its own configuration locally. The server (`nb250-10n`) is built on the desktop and pushed to it over SSH. The server needs no checkout of this repository.

| Host | How it's deployed | Command (from the repo root on the desktop) |
| --- | --- | --- |
| `shunya-dsktp` | Locally | `sudo nixos-rebuild switch --flake .#shunya-dsktp` |
| `nb250-10n` | Over SSH from the desktop | `nixos-rebuild switch --flake .#nb250-10n --target-host shunya@nb250-10n --sudo --ask-sudo-password` |

All commands below run from the repository root. Flakes only see files tracked by git, so **`git add` new files before building**.

---

## Building without deploying

Check that every host evaluates. This is the first step CI runs:

```bash
nix flake check
```

Build one host's full system without activating anything. No root is needed, and the result appears as `./result`:

```bash
nixos-rebuild build --flake .#nb250-10n
# equivalent:
nix build .#nixosConfigurations.nb250-10n.config.system.build.toplevel
```

Build every host, as CI does:

```bash
for host in shunya-dsktp nb250-10n; do
  nix build .#nixosConfigurations.$host.config.system.build.toplevel -o result-$host
done
```

See which packages a change adds, removes or upgrades compared with the running desktop:

```bash
nixos-rebuild build --flake .#shunya-dsktp
nix store diff-closures /run/current-system ./result
```

Useful flags while debugging:

| Flag | Effect |
| --- | --- |
| `-L` / `--print-build-logs` | Show full build logs |
| `--show-trace` | Full stack trace for evaluation errors |
| `nom build …` instead of `nix build …` | Readable progress output (`nix-output-monitor` is installed on every host) |

---

## Rebuild modes

`nixos-rebuild <mode>` takes the same flags on every host:

| Mode | Builds | Activates now | Becomes the boot default | Use it to… |
| --- | --- | --- | --- | --- |
| `build` | ✓ | | | Check a change compiles |
| `dry-activate` | ✓ | | | See which services *would* restart |
| `test` | ✓ | ✓ | | Try a change; a reboot returns to the previous one |
| `switch` | ✓ | ✓ | ✓ | Normal deploy |
| `boot` | ✓ | | ✓ | Apply on next reboot (kernel or bootloader changes) |

---

## Deploying the desktop

On the desktop itself:

```bash
sudo nixos-rebuild switch --flake .
```

Without an attribute (`.#name`), `nixos-rebuild` picks the configuration matching the current hostname, which is `shunya-dsktp`. Home Manager is applied in the same step, because it runs as a NixOS module.

---

## Deploying the server over SSH

From the desktop:

```bash
nixos-rebuild switch --flake .#nb250-10n --target-host shunya@nb250-10n --sudo --ask-sudo-password
```

What happens:

1. The configuration is evaluated and **built on the desktop**, which is much faster than the notebook.
2. The result is copied to `nb250-10n` over SSH as `shunya`. The server accepts the unsigned store paths because `wheel` is in its `nix.settings.trusted-users`.
3. On the server, `sudo` activates the new system. `--ask-sudo-password` asks once, up front, for `shunya`'s password **on the server**.
4. sops-nix decrypts the server's secrets **on the server** with its own SSH host key. No secret leaves the desktop in plain form.

| Flag | Meaning |
| --- | --- |
| `--flake .#nb250-10n` | Which configuration to build |
| `--target-host shunya@nb250-10n` | Where to copy and activate it. Use `shunya@10.9.97.186` if the name doesn't resolve. |
| `--sudo` | Use `sudo` on the target for activation |
| `--ask-sudo-password` | Prompt for that `sudo` password instead of failing without a terminal |
| `--build-host <host>` | *(optional)* Build somewhere else instead of locally |

This deploys the **working tree**, including uncommitted changes. Commit and push afterwards, so GitHub matches what's running.

### Don't put `sudo` in front

The deploy command used to be:

```bash
sudo nixos-rebuild --target-host shunya@nb250-10n switch --flake .#nb250-10n --sudo --ask-sudo-password
```

The leading `sudo` runs everything on the desktop as **root**, including SSH. SSH then uses root's keys and `/root/.ssh/known_hosts` instead of yours, and this machine's sudo setup doesn't pass your SSH agent through either. `nb250-10n` only accepts the keys listed in `modules/nixos/ssh.nix` (password login is disabled), so that form fails with `Permission denied (publickey)` unless root has its own authorized key.

It isn't needed anyway. Building and copying don't need root on the desktop, and `--sudo` takes care of root on the server.

### Other remote operations

All of these take the same `--target-host shunya@nb250-10n --sudo --ask-sudo-password` flags:

```bash
# Show what would restart, without changing anything
nixos-rebuild dry-activate --flake .#nb250-10n --target-host shunya@nb250-10n --sudo --ask-sudo-password

# Activate until the next reboot only
nixos-rebuild test --flake .#nb250-10n --target-host shunya@nb250-10n --sudo --ask-sudo-password

# Go back to the previous generation
nixos-rebuild switch --rollback --target-host shunya@nb250-10n --sudo --ask-sudo-password

# Make it the boot default, then reboot (kernel or bootloader changes)
nixos-rebuild boot --flake .#nb250-10n --target-host shunya@nb250-10n --sudo --ask-sudo-password
ssh -t shunya@nb250-10n sudo reboot
```

### Deploying from the server instead

If you're logged into the server and it has a checkout of this repository:

```bash
cd ~/.nixos && git pull
sudo nixos-rebuild switch --flake .
```

This builds on the notebook (slow) and only deploys what has been pushed.

---

## Updating

**Weekly updates.** The `update-flake-lock` workflow opens a pull request every Monday with a new `flake.lock`. Merge it, pull, then deploy every host. To update by hand:

```bash
nix flake update            # every input
nix flake update nixpkgs    # one input
git commit -m "flake: update flake.lock" flake.lock
```

**NixOS release upgrades** (for example 26.05 → 26.11):

1. Read the release notes' backward-incompatible changes.
2. Change the branch names in `flake.nix`: `nixos-26.11` for nixpkgs, `release-26.11` for Home Manager. Then run `nix flake update`.
3. Build every host and fix evaluation errors and warnings (renamed or removed options and packages).
4. Deploy, then reboot each host.

Never change `system.stateVersion` or `home.stateVersion` as part of an upgrade.

---

## After deploying

**Reboot when the kernel changed.** A switch can't load a new kernel. This prints `reboot needed` when the running kernel isn't the one the current system expects:

```bash
[ "$(readlink /run/booted-system/kernel)" = "$(readlink /run/current-system/kernel)" ] || echo "reboot needed"
```

Also reboot after release upgrades. Some changes, such as the D-Bus implementation or early boot (initrd), only take effect on boot.

**Check the server:**

```bash
ssh shunya@nb250-10n 'systemctl --failed; docker ps --format "table {{.Names}}\t{{.Status}}"'
```

**Rolling back:**
- Pick an older generation in the boot menu, or
- run `sudo nixos-rebuild switch --rollback` (desktop), or
- run the remote `--rollback` command above (server).

Garbage collection runs weekly and deletes generations older than one week (`modules/nixos/nix.nix`), so rollbacks only reach about a week back. To clean up by hand:

```bash
sudo nix-collect-garbage --delete-older-than 14d
```

---

## Troubleshooting

| Error | Cause and fix |
| --- | --- |
| `path '…/hosts/<name>' does not exist` | New files aren't tracked by git yet. `git add` them. |
| `Permission denied (publickey)` | SSH ran as root (leading `sudo`, see above), or your key isn't in `modules/nixos/ssh.nix`. |
| `Host key verification failed` | The server's host key changed (reinstall), or SSH ran as root with an empty `known_hosts`. Check the key, then remove the old one with `ssh-keygen -R nb250-10n`. |
| `sudo: a terminal is required to read the password` | Add `--ask-sudo-password`. |
| `lacks a signature by a trusted key` | The SSH user isn't trusted by Nix on the target. It must be in `wheel` (`nix.settings.trusted-users`). |
| A sops secret fails to decrypt during activation | The host's key isn't a recipient of `secrets/<host>.yaml`. Add it to `.sops.yaml` and run `sops updatekeys secrets/<host>.yaml`. |
