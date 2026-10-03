![nixfiles](https://socialify.git.ci/ItsShunya/nixfiles/image?custom_description=NixOS+dotfiles+for+all+my+machines&description=1&font=Raleway&forks=1&issues=1&language=1&logo=https%3A%2F%2Fcamo.githubusercontent.com%2F955fca7bc4a99f4142047a976fff46c50616dd7d2a20aa1bf36ea04104bb025c%2F68747470733a2f2f692e696d6775722e636f6d2f367146436c41312e706e67&name=1&owner=1&pattern=Signal&pulls=1&stargazers=1&theme=Light)


This repository contains the configuration files and scripts for managing my NixOS machines. It is designed for personal use but can serve as a reference for others interested in setting up and managing NixOS systems.

Feel free to use parts of this repository, but note that it is tailored to my specific needs and may require adjustments for your use case.

---

## Documentation

| Guide | Covers |
| --- | --- |
| [Structure](./docs/structure.md) | How the repository is organised, NixOS vs Home Manager, and where new things go |
| [Hosts](./docs/hosts.md) | Each machine, what it is used for and the services it runs |
| [Building and deploying](./docs/build-and-deploy.md) | Build commands, local and remote (SSH) deployment, updates, rollbacks |
| [Adding a host](./docs/add-host.md) | Step-by-step guide with templates for a new machine |

---

## Repository Structure

The repository is split into three layers: **modules** (one feature each), **profiles** (bundles of modules for a kind of machine) and **hosts** (one machine each). See [docs/structure.md](./docs/structure.md) for the full picture and where new things go.

```
flake.nix                  # inputs + mkHost; each host is wired up automatically
hosts/<name>/
  default.nix              # system: profile, bootloader, host-only settings
  hardware-configuration.nix
  home.nix                 # Home Manager for user shunya on this host
profiles/
  base.nix                 # every host
  desktop.nix              # base + X11/i3, audio, printing, desktop programs
  server.nix               # base + SSH server
modules/
  nixos/                   # NixOS modules, one file per feature
    homelab/               # containers behind an nginx reverse proxy
  home/                    # Home Manager modules
    desktop/               # i3, polybar, picom, alacritty, vscode
themes/                    # Stylix: color scheme, fonts and icons of the desktops
secrets/                   # sops-nix setup + encrypted secrets/<hostname>.yaml
assets/                    # wallpapers
docs/                      # detailed documentation
```

### Configuration Philosophy

- **Modules** do one thing and are enabled by importing them; they never import each other, except homelab services importing `homelab/common.nix`.
- **Profiles** are the only place that bundles modules. Each profile pulls in both the NixOS and the Home Manager side of its role.
- **Hosts** import exactly one profile and add what only that machine needs (bootloader, monitors, services).

Adding a machine typically involves the steps below; [docs/add-host.md](./docs/add-host.md) has the full guide with templates.
1. Creating `hosts/<name>/` with `default.nix`, `hardware-configuration.nix` and `home.nix`.
2. Importing `profiles/desktop.nix` or `profiles/server.nix` from `default.nix`.
3. Adding `<name>` to the host list in `flake.nix` and to the CI matrix in `.github/workflows/build.yml`.

### Secrets

Secrets are encrypted with [sops-nix](https://github.com/Mic92/sops-nix). Each host decrypts `secrets/<hostname>.yaml` at activation using its SSH host key; the recipients are listed in `.sops.yaml`.

- Edit secrets: `nix shell nixpkgs#sops -c sops secrets/<hostname>.yaml`. This needs your age key in `~/.config/sops/age/keys.txt`, derived from your SSH key with `ssh-to-age -private-key`.
- Add a host: convert its key with `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`, add it to `.sops.yaml`, then run `sops updatekeys secrets/<hostname>.yaml`.

---

## Initial Setup

To use a host configuration on a fresh NixOS installation, follow these steps:

1. **Set the Hostname**
   Ensure the hostname is set correctly:
   ```bash
   hostname <machine name>
   ```

2. **Connect to the Internet**
   Verify that the machine has internet access and the necessary credentials to clone this repository.

3. **Update the Configuration**
   Ensure the machine's configuration is up-to-date by pulling the latest changes from the repository.

4. **Backup Hardware Configuration**
   Replace the generated `hardware-configuration.nix` file with the one specific to the host:
   ```bash
   # Overwrite hardware-configuration.nix file with the generated one
   cp /etc/nixos/hardware-configuration.nix \
      ./hosts/$(hostname)/hardware-configuration.nix

   # Commit and push the new file
   git add hosts/$(hostname)/hardware-configuration.nix
   git commit -m "Add hardware-configuration for $(hostname)" && git push
   ```

5. **Deploy the Configuration**
   Apply the configuration using the NixOS rebuild command:
   ```bash
   sudo nixos-rebuild switch --flake .#$(hostname)
   ```

   To deploy a server from your desktop over SSH instead, see [Building and deploying](./docs/build-and-deploy.md#deploying-the-server-over-ssh).

---

## Current Hosts

| Configuration                                   | Type        | Location  | VPN IP         | Description                  |
| ----------------------------------------------- | ----------- | --------- | -------------- | ---------------------------- |
| [shunya-dsktp](./hosts/shunya-dsktp)            | Desktop     | Local     | `10.9.97.152`  | Main desktop machine         |
| [nb250-10n](./hosts/nb250-10n)                  | Server      | Local     | `10.9.97.186`  | Notebook acting as a server  |

What each host is used for and the services it runs are described in [docs/hosts.md](./docs/hosts.md).

---

## Continuous Integration (CI)

This repository uses a basic CI setup to validate configurations. The CI pipeline ensures that:

- The NixOS configurations are syntactically correct.
- Flake checks pass without errors.

To run the checks locally:
```bash
nix flake check
```

---

## Contributing

While this repository is primarily for personal use, I welcome constructive feedback, tips, and suggestions. If you notice areas for improvement or have ideas for better practices, feel free to open an issue or reach out.

---

## License

This repository is shared under the [Apache-2.0 License](./LICENSE). You are free to use and modify the code, but please give credit where it's due.

---

## Acknowledgments

Special thanks to the NixOS community for their excellent documentation and support, which made this setup possible.
