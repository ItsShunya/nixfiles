# Repository structure

This repository builds every machine I own from one flake. Its configuration is split into three layers:

| Layer | Folder | Answers the question |
| --- | --- | --- |
| **Modules** | `modules/` | *How* is one feature configured? (zsh, SSH, i3, a homelab service…) |
| **Profiles** | `profiles/` | *Which* features does a kind of machine get? (every host, desktops, servers) |
| **Hosts** | `hosts/` | *What* is specific to one physical machine? (hardware, bootloader, monitors, services) |

Each layer only builds on the one below it: hosts import a profile, and profiles import modules.

```
.
├── flake.nix                 # inputs, and the mkHost helper that builds each host
├── flake.lock                # exact pinned versions of every input
├── hosts/
│   ├── shunya-dsktp/         # main desktop
│   │   ├── default.nix       #   NixOS side of this machine
│   │   ├── hardware-configuration.nix
│   │   └── home.nix          #   Home Manager side of this machine
│   └── nb250-10n/            # notebook acting as a server
├── profiles/
│   ├── base.nix              # every host
│   ├── desktop.nix           # base + graphical session, audio, printing
│   └── server.nix            # base + SSH server
├── modules/
│   ├── nixos/                # NixOS modules (system level)
│   │   └── homelab/          #   containers behind an nginx reverse proxy
│   └── home/                 # Home Manager modules (user level)
│       └── desktop/          #   graphical programs and their dotfiles
├── themes/                   # Stylix: color scheme, fonts and icons of the desktops
├── secrets/                  # sops-nix setup and encrypted secrets per host
├── assets/                   # files referenced by the config (wallpapers)
├── docs/                     # this documentation
└── .github/workflows/        # CI: build every host, weekly flake.lock update
```

---

## How a host is built

`flake.nix` defines a small helper, `mkHost`, and calls it for every host name in its list. For a host called `nb250-10n`, it:

1. Loads `hosts/nb250-10n/default.nix` as the NixOS configuration.
2. Adds the Home Manager NixOS module and loads `hosts/nb250-10n/home.nix` as the Home Manager configuration of user `shunya`.
3. Sets `networking.hostName = "nb250-10n"`, so the folder name *is* the hostname.
4. Passes the flake `inputs` to every module, which is how `secrets/default.nix` reaches sops-nix.

From there, the imports cascade:

```
flake.nix  mkHost "nb250-10n"
├── hosts/nb250-10n/default.nix                       NixOS
│   ├── ./hardware-configuration.nix
│   ├── profiles/server.nix
│   │   ├── profiles/base.nix
│   │   │   ├── modules/nixos/{nix,locale,networking,zsh,user,packages}.nix
│   │   │   └── home: modules/home/{base,git}.nix      ──┐
│   │   └── modules/nixos/ssh.nix                         │
│   ├── secrets/                                          │ merged into the
│   └── modules/nixos/homelab/{home-assistant,fava,omeka}.nix  Home Manager config
└── hosts/nb250-10n/home.nix                          ────┘ of user shunya
```

The name `nb250-10n` is used in four places, and they must match:

- the folder `hosts/nb250-10n/`
- the entry in the `flake.nix` host list (and so the flake attribute `.#nb250-10n`)
- the hostname of the running machine
- the secrets file `secrets/nb250-10n.yaml`, if it has one

---

## NixOS vs Home Manager

The repository uses two module systems. Both are written in Nix, but each has its own set of options.

| | NixOS (`modules/nixos/`) | Home Manager (`modules/home/`) |
| --- | --- | --- |
| Scope | The whole machine | One user (`shunya`) |
| Manages | Boot, kernel, drivers, filesystems, system services, users and groups, firewall, `/etc`, system-wide packages | Dotfiles in `~`, per-program settings (git, i3, polybar, alacritty…), user services, per-user packages |
| Example options | `services.openssh`, `boot.loader`, `networking.firewall` | `programs.git`, `xsession.windowManager.i3`, `home.file` |
| Needs root? | Yes | No, but here it's applied by `nixos-rebuild` |

Home Manager runs **as a NixOS module** here. There is no separate `home-manager switch`: `sudo nixos-rebuild switch` builds and activates both layers together. Two settings in `mkHost` shape how that works:

- `useGlobalPkgs = true`: Home Manager uses the same `pkgs` as the system, so `nixpkgs.config` (such as `allowUnfree`) applies to it too.
- `useUserPackages = true`: `home.packages` are installed into `/etc/profiles/per-user/shunya` instead of `~/.nix-profile`.

**The two systems don't mix in `imports`.** A Home Manager module listed in a NixOS `imports` (or the other way round) fails with "option does not exist". The bridge is the NixOS option `home-manager.users.shunya.imports`, which takes a list of Home Manager modules. Profiles use it to pull in the user side of their role:

```nix
# profiles/desktop.nix (NixOS module)
{
  imports = [ ../modules/nixos/x11.nix ];                          # NixOS modules
  home-manager.users.shunya.imports = [ ../modules/home/desktop/i3.nix ];  # Home Manager modules
}
```

**Which one should a setting go in?** If it needs root or affects the machine (a service, a driver, a port, a font for the login screen), it goes in NixOS. If it's about how a program behaves for you, or a file in your home folder, it goes in Home Manager. A command-line tool you use yourself belongs in Home Manager (`home.packages`). Something every user, root or a service needs belongs in NixOS (`environment.systemPackages`).

---

## Folder by folder

### `flake.nix` and `flake.lock`

`flake.nix` declares four **inputs** and produces one **output**.

| Input | What it is |
| --- | --- |
| `nixpkgs` | NixOS and all packages, on the `nixos-26.05` release branch |
| `home-manager` | Home Manager, on the matching `release-26.05` branch |
| `sops-nix` | Decrypts secrets on the host when the configuration is activated |
| `stylix` | Applies one color scheme and set of fonts to the desktop programs (see [`themes/`](#themes)), on its `release-26.05` branch |

`home-manager`, `sops-nix` and `stylix` follow our `nixpkgs`, so only one copy of nixpkgs is evaluated.

The output, `nixosConfigurations.<host>`, is what `nixos-rebuild --flake .#<host>` builds.

`flake.lock` pins every input to an exact commit. Builds are reproducible until you update it with `nix flake update`. The `update-flake-lock` workflow opens a pull request with that update every Monday.

When moving to a new NixOS release, change the branch names in `flake.nix` (`nixos-YY.MM`, `release-YY.MM`). Do **not** change `stateVersion` (see [Conventions](#conventions)).

### `hosts/`

One folder per physical machine, always with three files:

| File | Contents |
| --- | --- |
| `default.nix` | Imports `hardware-configuration.nix` and **one** profile. Then everything only this machine needs: bootloader, drivers, homelab services, overrides, `system.stateVersion`. |
| `hardware-configuration.nix` | Generated by `nixos-generate-config` on the machine: disks, filesystems, kernel modules, CPU. Regenerate it rather than editing it. |
| `home.nix` | This machine's Home Manager settings: monitor layout, wallpapers, programs only used here, `home.stateVersion`. |

The rule: if **two or more** hosts would need the same lines, they don't belong in `hosts/`. Move them into a module or a profile.

### `profiles/`

A profile describes a kind of machine by listing the modules it gets, on both the NixOS and the Home Manager side. Profiles are the **only** files that bundle modules together.

| Profile | Imports | Home Manager |
| --- | --- | --- |
| `base.nix` | nix, locale, networking, zsh, user, packages | `base.nix`, `git.nix` |
| `desktop.nix` | `base.nix` + x11, audio, printing, `themes/` | i3, polybar, picom, alacritty, vscode, `themes/home.nix` |
| `server.nix` | `base.nix` + ssh | (nothing beyond base) |

A host imports exactly one of `desktop.nix` or `server.nix`, never `base.nix` directly. If a new kind of machine appears (say a laptop that's a desktop plus Wi-Fi and battery tweaks), create `profiles/laptop.nix` that imports `./desktop.nix` and adds the extras.

### `modules/nixos/`

System-level modules, one feature per file. A module is switched on by importing it; there are no `enable` flags of our own.

| File | Purpose | Used by |
| --- | --- | --- |
| `nix.nix` | Flakes, trusted users, weekly garbage collection and store optimisation, `allowUnfree` | base |
| `locale.nix` | Time zone, locale (`en_GB` + Spanish formats), console keymap | base |
| `networking.nix` | NetworkManager | base |
| `zsh.nix` | zsh as the default shell for every user | base |
| `user.nix` | The `shunya` account: groups, default shell, neovim | base |
| `packages.nix` | System-wide basics (`git`, `wget`) and `nix-ld` for running foreign binaries | base |
| `x11.nix` | X server, Spanish keyboard layout, i3 inside an Xfce session, LightDM + slick greeter, Firefox, Thunar, polkit | desktop |
| `audio.nix` | PipeWire with PulseAudio and ALSA compatibility | desktop |
| `printing.nix` | CUPS | desktop |
| `ssh.nix` | OpenSSH server, key-only login, the authorized keys for `shunya` | server |

#### `modules/nixos/homelab/`

Self-hosted services, each running as a Docker container (`virtualisation.oci-containers`) behind nginx.

- **`common.nix`** is the shared base. It defines two options of our own:
  - `homelab.domain` (default `shunya.lan`)
  - `homelab.proxies.<name>.port`

  For every entry in `homelab.proxies` it generates an nginx virtual host `<name>.<domain>` that proxies to `127.0.0.1:<port>`. It also opens port 80, selects the Docker backend, and adds `shunya` to the `docker` group.
- **One file per service** (`home-assistant.nix`, `fava.nix`, `omeka.nix`). Each one imports `./common.nix`, registers its proxy, and defines its containers. Importing a service file from a host is what deploys it there.

Services are only reachable through nginx. Containers publish their ports on `127.0.0.1` (or use `--network=host` with the firewall closed), and only port 80 is open. Secrets that a container needs come from sops (see `omeka.nix` for the `sops.templates` pattern that renders an env file).

### `modules/home/`

User-level (Home Manager) modules.

| Path | Purpose | Used by |
| --- | --- | --- |
| `base.nix` | Everyday CLI tools (archives, networking, tracing, `fastfetch`…), `EDITOR=nvim`, bash settings | base |
| `git.nix` | Git identity | base |
| `desktop/i3.nix` | i3 settings: gaps, keybindings, Firefox autostart | desktop |
| `desktop/polybar/` | The status bar (see below) | desktop |
| `desktop/picom.nix` | Compositor: fades, shadows, Alacritty opacity | desktop |
| `desktop/alacritty/` | Terminal: `default.nix` enables it; the generated config imports the hand-written `alacritty.toml` (colors and font come from Stylix) | desktop |
| `desktop/vscode.nix` | VS Code | desktop |

**Polybar** is split into small parts:

- `default.nix` enables the service and imports the parts the bar uses.
- `config.nix` sets the package and global settings.
- `bars/main.nix` defines the bar itself, including which parts appear in `modules-left`, `modules-center` and `modules-right`.
- `modules/<group>/<part>.nix` each define one bar segment (`cpu`, `memory`, `eth`, `wlan`, …).

Some parts (`wlan`, `filesystem`, `xkeyboard`, `whoami`) aren't used yet. To use one, import it in `default.nix` (or in a host's `home.nix` for one machine only) and add its name to the bar.

### `themes/`

How the desktops look. [Stylix](https://github.com/nix-community/stylix) takes one [base16](https://github.com/tinted-theming/home) color scheme (16 colors, `base00`–`base0F`) and a set of fonts, and writes them into the config of every program it has a *target* for. Programs are *configured* in `modules/`; how they *look* comes from here. Only `profiles/desktop.nix` imports it, so servers never load Stylix.

| File | Kind | Contents |
| --- | --- | --- |
| `default.nix` | NixOS module | Imports Stylix and sets the scheme (Catppuccin Mocha), fonts, icon theme (Papirus), login screen background, and the system-side targets. Also extra font packages and the greeter's GTK theme |
| `home.nix` | Home Manager module | The user-side targets, Polybar's fonts, and the `palette` argument |
| `palette.nix` | Function of the scheme | Colors for what Stylix doesn't theme (Polybar, the i3lock command), named by role and mapped to scheme slots |

Stylix runs as a NixOS module, and it sets up its Home Manager half for `shunya` automatically with the same scheme, fonts and icons. Only the target switches are separate, which is why `home.nix` has its own list.

**Targets are opt-in.** `stylix.autoEnable = false` means only the targets listed in the two files are themed:

| Side | Targets |
| --- | --- |
| NixOS (`default.nix`) | `console` (TTY colors), `font-packages`, `fontconfig` (default fonts), `gtk` (dconf), `lightdm` (background) |
| Home Manager (`home.nix`) | `alacritty`, `gtk` (GTK 2/3/4 apps such as Thunar), `i3` (window borders, font) |

Left on, Stylix also themes programs that aren't installed (GNOME, KDE, Blender…), and a weekly flake update could switch on new targets. `feh` stays off because each host sets its own wallpaper per monitor.

**VS Code** is not a Stylix target. Stylix themes it with an extension, and once Home Manager installs any extension it rewrites `extensions.json` whenever that extension changes; VS Code then deletes every extension installed from the marketplace. VS Code uses the "Catppuccin Mocha" theme from the marketplace instead, which matches the scheme.

**Alacritty** is enabled with `programs.alacritty`. Home Manager writes `~/.config/alacritty/alacritty.toml` with Stylix's colors and font, and that file imports the hand-written `modules/home/desktop/alacritty/alacritty.toml` for everything else.

**Polybar and i3lock** have no Stylix target. Their colors come from `palette`, a module argument that `home.nix` builds from the active scheme:

```nix
# themes/palette.nix: role = scheme slot
background = base01;   # base16's status bar background
volume = base0B;       # green

# modules/home/desktop/polybar/modules/network/eth.nix
{ palette, ... }:
{
  services.polybar.config."module/eth".label-connected =
    "%{F${palette.primary}}%ifname%%{F-} %local_ip%";
}
```

`palette` only exists where `themes/home.nix` is imported. A module that takes it fails with "attribute 'palette' missing" on a server, so only use it in desktop modules.

**Changing the scheme** is one line, `stylix.base16Scheme` in `default.nix`. List the available schemes with:

```bash
ls $(nix build --no-link --print-out-paths nixpkgs#base16-schemes)/share/themes
```

After a switch, `~/.config/stylix/palette.html` shows the active scheme's 16 colors.

Per-monitor wallpapers stay in each host's `home.nix`, because which image fits depends on that machine's monitors.

### `secrets/`

Encrypted with [sops](https://github.com/getsops/sops) and decrypted at activation by [sops-nix](https://github.com/Mic92/sops-nix).

| File | Purpose |
| --- | --- |
| `default.nix` | Imports sops-nix and points it at `secrets/<hostname>.yaml`. Decrypts with the host's SSH key (`/etc/ssh/ssh_host_ed25519_key`), so there is no separate key to copy to servers. A host that has secrets imports `../../secrets`. |
| `<hostname>.yaml` | That host's secrets. Key names are readable; values are encrypted. |
| `/.sops.yaml` (repository root) | Who can decrypt what: an `admin` key (derived from your SSH key) plus each host's key, and one `creation_rules` entry per secrets file. |

A module uses a secret by declaring it and reading its decrypted path, which lives under `/run/secrets`, never in the Nix store:

```nix
sops.secrets."omeka/db_password" = { };   # key omeka.db_password in secrets/<host>.yaml
# config.sops.secrets."omeka/db_password".path  →  /run/secrets/omeka/db_password
```

Edit secrets from the repository root with `nix shell nixpkgs#sops -c sops secrets/<host>.yaml`. That needs your age key in `~/.config/sops/age/keys.txt`.

### `assets/`

Binary files the configuration references by path. Right now that's `assets/wallpaper/`, used by the login screen (`themes/default.nix`) and the desktop background (`hosts/shunya-dsktp/home.nix`). Files are copied into the Nix store at build time, so changing one triggers a rebuild of whatever uses it.

### `.github/workflows/`

| Workflow | Runs | Does |
| --- | --- | --- |
| `build.yml` | On push and pull request to `main` | `nix flake check`, then builds every host in its `matrix.hostname` list |
| `update-flake-lock.yml` | Mondays at 04:00 UTC, or manually | Opens a pull request that updates `flake.lock` |

Pull requests opened by the update workflow only trigger `build.yml` if a `FLAKE_UPDATE_TOKEN` secret (a fine-grained personal access token) is set. Otherwise, close and reopen the PR to run the build.

### Other root files

| File | Purpose |
| --- | --- |
| `.sops.yaml` | sops recipients and rules (see [secrets](#secrets)) |
| `.pre-commit-config.yaml` | Formats `.nix` files with `nixfmt` on commit, after you run `pre-commit install` once |
| `.editorconfig` | 2-space indentation for Nix, LF line endings |

---

## Conventions

- **One feature per module file.** Use a folder only when a module has more than one file (`alacritty/` with its TOML, `polybar/` with its parts). Never add a `default.nix` whose only job is to import other files: bundling is the profiles' job.
- **Import to enable.** Modules have no `enable` options of our own. The exception is `homelab.proxies`, because many services share one nginx.
- **Modules don't import each other**, except homelab services importing `homelab/common.nix` and polybar's internal parts.
- **No colors or fonts in `modules/`.** A program Stylix supports gets them from its target, enabled in `themes/`. For anything else, add a role to `themes/palette.nix` and read it as `palette.<role>`.
- **Hosts import exactly one profile.**
- **Overriding a shared value.** Lists (packages, firewall ports, groups) merge across modules, so just add to them. A single value that's already set elsewhere (like `networking.networkmanager.enable = true` in base) can't be redefined with a different value; use `lib.mkForce`. If several hosts end up forcing the same thing, move that setting out of the shared module instead.
- **`stateVersion` is set once.** `system.stateVersion` (in `default.nix`) and `home.stateVersion` (in `home.nix`) record the release a machine was *installed* with. They keep defaults for existing data stable, so leave them alone when upgrading NixOS.
- **Formatting:** `nixfmt` on every `.nix` file.
- **Commit messages:** one line, `scope: message` (`server: remove dnsmasq`, `i3wm: swap screens`).

---

## Where does new stuff go?

| I want to… | Put it in |
| --- | --- |
| Install a CLI tool for myself on every machine | `modules/home/base.nix` → `home.packages` |
| Install a tool system-wide on every machine (for root, services, scripts) | `modules/nixos/packages.nix` → `environment.systemPackages` |
| Install a GUI app on every desktop | A new `modules/home/desktop/<app>.nix`, imported in `profiles/desktop.nix` |
| Install something on one machine only | That host's `home.nix` (user) or `default.nix` (system) |
| Configure a program's dotfiles | A Home Manager module (`programs.<name>` if Home Manager has one, else `home.file`) |
| Add a system service to every server | A new `modules/nixos/<service>.nix`, imported in `profiles/server.nix` |
| Add a system service to one server | That host's `default.nix`, or a new module if it's more than a few lines |
| Self-host a web app in a container | A new `modules/nixos/homelab/<service>.nix` (see [add-host.md](add-host.md#homelab-service)) and import it from the host |
| Add a password or token | `secrets/<host>.yaml` via `sops`, declared with `sops.secrets` in the module that uses it |
| Add a driver used by some machines (NVIDIA, Wi-Fi firmware) | A new `modules/nixos/<driver>.nix`, imported by those hosts |
| Change a monitor layout, wallpaper or bar for one machine | That host's `home.nix` |
| Change the color scheme, fonts, icons or login screen background | `stylix` in `themes/default.nix` |
| Change which scheme color the bar or lock screen uses | `themes/palette.nix` |
| Theme a newly added program | Enable its Stylix target in `themes/home.nix` (or `themes/default.nix` for system targets); if Stylix has none, read colors from `palette` |
| Change a setting for every host | The module that owns it (`locale.nix`, `nix.nix`, …), or a new module imported by `profiles/base.nix` |
| Add a new kind of machine (laptop, VM) | A new `profiles/<kind>.nix` built on an existing profile |
| Add a wallpaper or other file | `assets/` |
| Add a machine | See [add-host.md](add-host.md) |

---

## Checking a change

Build without switching, then compare with what's running:

```bash
nix flake check                                        # evaluates every host
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nix store diff-closures /run/current-system ./result   # package changes
sudo nixos-rebuild switch --flake .#<host>             # apply
```

Flakes only see files that git tracks. **`git add` new files before building**, or Nix reports that the path doesn't exist.

For deployment, remote hosts, updates and rollbacks, see [build-and-deploy.md](build-and-deploy.md). For what runs on each machine, see [hosts.md](hosts.md).
