# Hosts

The machines managed by this repository, what each one is for, and what runs on it. To add a machine, see [add-host.md](add-host.md). To deploy one, see [build-and-deploy.md](build-and-deploy.md).

| Host | Type | Profile | VPN IP | Purpose |
| --- | --- | --- | --- | --- |
| [`shunya-dsktp`](#shunya-dsktp) | Desktop | `desktop` | `10.9.97.152` | Main workstation and admin machine for the others |
| [`nb250-10n`](#nb250-10n) | Server | `server` | `10.9.97.186` | Old notebook running the self-hosted services |

```
                     LAN — OpenWrt router (DHCP, DNS for *.shunya.lan)
                                       │
         ┌─────────────────────────────┴───────────────────────────────┐
         │                                                             │
┌────────┴─────────────┐   nixos-rebuild --target-host   ┌─────────────┴──────────────────┐
│ shunya-dsktp         │ ──────────── SSH :22 ─────────► │ nb250-10n                      │
│ niri desktop         │                                 │ nginx :80                      │
│ builds every host    │                                 │  ├ home.shunya.lan   → :8123   │
│ holds the sops       │ ─── browser http://*.shunya.lan │  ├ fava.shunya.lan   → :5000   │
│ admin key            │ ──────────────────────────────► │  └ museum.shunya.lan → :8081   │
└──────────────────────┘                                 │ Docker containers              │
                                                         └────────────────────────────────┘
```

---

## shunya-dsktp

**Main desktop.** It's where I work, and the admin machine for the rest:

- It builds every host and deploys the server over SSH.
- It holds the `admin` sops key used to edit the encrypted secrets.
- Its SSH key is the one the server accepts.

| | |
| --- | --- |
| Configuration | [`hosts/shunya-dsktp/`](../hosts/shunya-dsktp) · profile [`desktop-niri`](../profiles/desktop-niri.nix) |
| Hardware | Intel CPU, NVMe SSD (ext4 root, no swap), UEFI firmware |
| Boot | systemd-boot, keeps the last 5 generations |
| Displays | Two monitors: `DP-2` rotated left (portrait), `DP-1` to its right |
| Network | NetworkManager; firewall with no open ports; no SSH server |

### Desktop session

The desktop runs **niri**, a scrolling tiling Wayland compositor, through the [`desktop-niri`](../profiles/desktop-niri.nix) profile. The ReGreet greeter (on greetd) starts it. X11 programs such as Krita run through xwayland-satellite, which niri starts when one opens. Electron apps (VS Code, GitKraken) run on Wayland directly.

| Component | What it does | Configured in |
| --- | --- | --- |
| niri | Compositor and window manager: gaps, borders, shadows, translucent Alacritty, keybindings, Firefox autostart | `modules/home/desktop/niri.nix` |
| Waybar | Status bar, with the same segments Polybar had: power, date, workspaces on the left; window title in the centre; memory, CPU, network, volume, hostname, kernel on the right | `modules/home/desktop/waybar.nix` |
| ReGreet | Login screen, running in its own niri instance (not cage, which spreads it over every monitor). Shown on `DP-1` only: the greeter's niri config turns `DP-2` off. Stylix warns about this custom greetd command on every rebuild; the theme still applies | `modules/nixos/niri.nix`, `DP-2` setting in `hosts/shunya-dsktp/default.nix` |
| fuzzel, swaylock, mako | App launcher (`Mod+D`), lock screen (`Mod+Shift+X`), notifications | `modules/home/desktop/niri.nix` |
| swaybg | Wallpapers, one per monitor, from `assets/wallpaper/` | `hosts/shunya-dsktp/home.nix` |
| niri `output` blocks | Monitor layout: `DP-2` rotated (`transform "90"`) at the left, `DP-1` to its right | `hosts/shunya-dsktp/home.nix` |
| Theme | Stylix with the Catppuccin Mocha scheme across Waybar, fuzzel, swaylock, mako, Alacritty, GTK apps, the console and the login screen; niri's border colors come from `themes/palette.nix`. Fantasque Sans Mono, Papirus icons. VS Code uses the matching Catppuccin Mocha theme from the marketplace | `themes/` |

`Mod+F1` lists every keybinding. They follow the old i3 ones where i3 had one (`Mod+Return` terminal, `Mod+Shift+Q` close, arrows to focus and with `Shift` to move, `Mod+Ctrl+←/→` to send a workspace to the other monitor, `Mod+X` screenshot to the clipboard). Niri reloads `~/.config/niri/config.kdl` by itself after a switch, so there's no reload key.

#### Going back to i3

The i3 setup (LightDM, i3, Polybar, picom, feh, xrandr) is still in the repository, only inactive on this host. To use it again, change the profile import in [`hosts/shunya-dsktp/default.nix`](../hosts/shunya-dsktp/default.nix) from `desktop-niri.nix` to `desktop-i3.nix` and switch. `home.nix` keeps the monitor and wallpaper settings for both, in two marked sections. Each profile only reads its own section.

### Programs

| Kind | Programs |
| --- | --- |
| Everyday | Firefox, Alacritty, Thunar (with gvfs and tumbler), VS Code |
| Development | GitKraken, git, neovim |
| Graphics | Krita |
| Working on this repo | `nixfmt`, `pre-commit` |

### System services

| Service | Purpose |
| --- | --- |
| PipeWire | Audio, with PulseAudio and ALSA compatibility |
| CUPS | Printing |
| NetworkManager | Wired and wireless networking |
| Nix garbage collection and optimisation | Weekly; removes generations older than a week |

---

## nb250-10n

**Home server.** An old notebook that's always on and hosts the self-hosted services: home automation, personal finances, and a digital collection ("museum") site. Each service is reachable on the LAN by name through nginx.

| | |
| --- | --- |
| Configuration | [`hosts/nb250-10n/`](../hosts/nb250-10n) · profile [`server`](../profiles/server.nix) |
| Hardware | Intel CPU, single disk (ext4 root + swap partition), Ethernet and Wi-Fi, BIOS firmware |
| Boot | GRUB on `/dev/sda` |
| Access | SSH as `shunya`, keys only (password login disabled); `sudo` requires the password |
| Firewall | TCP 22 (SSH) and 80 (nginx); nothing else is reachable from the network |
| Secrets | [`secrets/nb250-10n.yaml`](../secrets/nb250-10n.yaml), decrypted at activation with the host's SSH key |

### Services

All services run as Docker containers managed by NixOS (`virtualisation.oci-containers`), each as a `docker-<container>.service` systemd unit. nginx on port 80 forwards each name to the service's local port.

| Service | URL | Container | Image | Data |
| --- | --- | --- | --- | --- |
| **Home Assistant** (home automation) | http://home.shunya.lan | `homeassistant` | `ghcr.io/home-assistant/home-assistant:2026.2.2` | Docker volume `home-assistant` → `/config` |
| **Fava** (personal finances; web UI for a Beancount ledger) | http://fava.shunya.lan | `finance` | `ghcr.io/itsshunya/finance-tracker:release` | `/home/shunya/finance-tracker/ledger` → `/data` |
| **Omeka S** ("Shunya's museum" collection site) | http://museum.shunya.lan | `omeka` | `giocomai/omeka-s-docker:v4.2.0` | Docker volume `omeka` |
| MariaDB (Omeka's database) | internal only | `omeka_mariadb` | `mariadb:latest` | Docker volume `omeka_mariadb` |
| phpMyAdmin (database admin) | via SSH tunnel | `omeka_pma` | `phpmyadmin/phpmyadmin:latest` | none |

Per-service details:

- **Home Assistant** uses the host network, so it can discover devices on the LAN, and runs `--privileged`, which gives it access to host hardware. It listens on port 8123; the firewall blocks direct access, so use the nginx name. Defined in [`homelab/home-assistant.nix`](../modules/nixos/homelab/home-assistant.nix).
- **Fava** runs my own `finance-tracker` image on the host network, on port 5000. The ledger files live in my home folder on the server. Defined in [`homelab/fava.nix`](../modules/nixos/homelab/fava.nix).
- **Omeka S** runs with the `default` and `freedom` themes and the Common, EasyAdmin, Adminer and CustomOntology modules. It, MariaDB and phpMyAdmin share a private Docker network, `omeka-net`; only Omeka's web port (`127.0.0.1:8081`) and phpMyAdmin's (`127.0.0.1:8080`) are published, both on localhost only. Its database and admin passwords come from sops, rendered into `/run/secrets/rendered/omeka-{db,app}.env`. Defined in [`homelab/omeka.nix`](../modules/nixos/homelab/omeka.nix).
- **phpMyAdmin** is not exposed through nginx. Reach it through an SSH tunnel:

  ```bash
  ssh -L 8080:localhost:8080 shunya@nb250-10n
  # then open http://localhost:8080
  ```

### Supporting services

| Service | Purpose |
| --- | --- |
| OpenSSH | Remote administration and deployments |
| nginx | Reverse proxy for the `*.shunya.lan` names; generated from `homelab.proxies` in [`homelab/common.nix`](../modules/nixos/homelab/common.nix) |
| Docker | Runs the containers; `shunya` is in the `docker` group |
| sops-nix | Decrypts `secrets/nb250-10n.yaml` at activation |
| Nix garbage collection and optimisation | Weekly |

DNS for `*.shunya.lan` is served by the OpenWrt router, not by this host. Every service name must point at `10.9.97.186`.

### Operating it

```bash
ssh shunya@nb250-10n

docker ps                                   # running containers
docker logs -f homeassistant                # a container's logs
journalctl -u docker-omeka.service -f       # the systemd unit around it
sudo systemctl restart docker-finance.service
systemctl --failed                          # anything broken
```

Container data lives in Docker volumes under `/var/lib/docker/volumes/` (`home-assistant`, `omeka`, `omeka_mariadb`), plus Fava's ledger in `/home/shunya/finance-tracker/ledger`. Those are the paths to back up. Everything else is rebuilt from this repository.
