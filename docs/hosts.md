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
│ i3 desktop           │                                 │ nginx :80                      │
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
| Configuration | [`hosts/shunya-dsktp/`](../hosts/shunya-dsktp) · profile [`desktop`](../profiles/desktop.nix) |
| Hardware | Intel CPU, NVMe SSD (ext4 root, no swap), UEFI firmware |
| Boot | systemd-boot, keeps the last 5 generations |
| Displays | Two monitors: `DP-2` rotated left (portrait), `DP-1` to its right |
| Network | NetworkManager; firewall with no open ports; no SSH server |

### Desktop session

LightDM with the slick greeter starts an Xfce session without its desktop, used only for Xfce's tools, running the **i3** window manager. On top of that:

| Component | What it does | Configured in |
| --- | --- | --- |
| i3 | Tiling window manager: gaps, keybindings, Firefox autostart | `modules/home/desktop/i3.nix` |
| Polybar | Status bar: power, date, workspaces on the left; memory, CPU, Ethernet, volume, hostname, kernel on the right | `modules/home/desktop/polybar/` |
| picom | Compositor: fades, shadows, translucent Alacritty | `modules/home/desktop/picom.nix` |
| feh | Wallpapers, one per monitor, from `assets/wallpaper/` | `hosts/shunya-dsktp/home.nix` |
| xrandr | Monitor layout, applied at i3 start | `hosts/shunya-dsktp/home.nix` |

### Programs

| Kind | Programs |
| --- | --- |
| Everyday | Firefox, Alacritty, Thunar, VS Code |
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
