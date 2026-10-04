# Adding a host

A host is one folder with three files, plus two list entries. This guide walks through it from a fresh NixOS install to a deployed machine. For what each folder is for, see [structure.md](structure.md).

**Summary**

1. Pick a name, a profile and a bootloader.
2. Create `hosts/<name>/` with `default.nix`, `hardware-configuration.nix` and `home.nix`.
3. Add `<name>` to `flake.nix` and to the CI matrix.
4. Optional: host-specific settings, secrets, SSH keys.
5. Build, then switch the machine to the new configuration.

---

## 1. Before you start

Install NixOS on the machine with the official installer. Any user and any configuration will do: this repository replaces them on the first switch. Then gather three things.

**A name.** It becomes the folder name, the flake attribute (`.#<name>`), the machine's hostname and the secrets filename. Use lowercase letters, digits and dashes (`nb250-10n`, `media-srv`).

**A profile.**

| The machine… | Profile |
| --- | --- |
| has a screen you work on, with the niri (Wayland) desktop | `profiles/desktop-niri.nix` |
| has a screen you work on, with the i3 (X11) desktop | `profiles/desktop-i3.nix` |
| runs headless and you reach it over SSH | `profiles/server.nix` |

**Firmware type**, which decides the bootloader. On the new machine, run:

```bash
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
```

**The release it was installed with**, for `stateVersion`. On the new machine, `nixos-version` prints something like `26.05.20261002.774debe`; use the first part (`26.05`).

---

## 2. Create the host folder

```
hosts/<name>/
├── default.nix                  # NixOS side
├── hardware-configuration.nix   # generated on the machine
└── home.nix                     # Home Manager side
```

### `hardware-configuration.nix`

The installer already generated it at `/etc/nixos/hardware-configuration.nix`. Copy that file, or regenerate it on the machine:

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Don't edit it by hand. If the disks change, regenerate it.

### `default.nix`

**Server (BIOS, GRUB):**

```nix
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../profiles/server.nix
  ];

  # Install GRUB on the boot disk. Prefer a stable /dev/disk/by-id/ path
  # over /dev/sdX, which can change between boots.
  boot.loader.grub = {
    enable = true;
    device = "/dev/disk/by-id/<boot-disk>";
  };

  # The NixOS release this machine was installed with (see step 1).
  # NOTE: Only update it on clean installs.
  system.stateVersion = "26.05";
}
```

List the disk IDs with `ls -l /dev/disk/by-id/`. Pick the whole disk (no `-partN` suffix) that `/` lives on.

**Desktop (UEFI, systemd-boot):**

```nix
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../profiles/desktop-niri.nix # or ../../profiles/desktop-i3.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };

  # The NixOS release this machine was installed with (see step 1).
  # NOTE: Only update it on clean installs.
  system.stateVersion = "26.05";
}
```

The firmware type decides the bootloader, not the profile. A UEFI server uses the systemd-boot block, and a BIOS desktop uses the GRUB block.

You don't set `networking.hostName`: `mkHost` sets it from the folder name.

### `home.nix`

**Server:** nothing beyond the base Home Manager setup, so only the state version is needed:

```nix
{
  # The release this machine was installed with; same value as
  # system.stateVersion in default.nix.
  # NOTE: Only update it on clean installs.
  home.stateVersion = "26.05";
}
```

**Desktop:** monitor layout, wallpaper and programs only this machine needs. How you set the monitors and wallpaper depends on the profile.

With `desktop-niri.nix`, add them to niri's config:

```nix
{ pkgs, ... }:

let
  wallpaper_src = ../../assets/wallpaper;
in
{
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  # Programs only this machine needs.
  home.packages = with pkgs; [
  ];

  # Appended to the niri config from modules/home/desktop/niri.nix.
  xdg.configFile."niri/config.kdl".text = ''
    output "<OUTPUT-1>" {
        position x=0 y=0
    }
    output "<OUTPUT-2>" {
        position x=<width of OUTPUT-1> y=0
    }

    spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-o" "<OUTPUT-1>" "-i" "${wallpaper_src}/sky_sunset_h.jpg" "-m" "fill" "-o" "<OUTPUT-2>" "-i" "${wallpaper_src}/sky_night_v.jpg" "-m" "fill"
  '';

  # NOTE: Only update it on clean installs.
  home.stateVersion = "26.05";
}
```

Find the monitor names (`DP-1`, `HDMI-A-1`, …) with `niri msg outputs` once the desktop is running. A rotated monitor takes `transform "90"` (or `"270"`) in its `output` block. With a single monitor, drop the `output` blocks and pass one `-i` without `-o` to swaybg.

With `desktop-i3.nix`, set them at i3 start with xrandr and feh:

```nix
{ lib, pkgs, ... }:

let
  wallpaper_src = ../../assets/wallpaper;
in
{
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  # Programs only this machine needs.
  home.packages = with pkgs; [
  ];

  # Wallpapers, one per monitor; feh below reads these paths.
  home.file.".wallpaper1".source = "${wallpaper_src}/sky_sunset_h.jpg";
  home.file.".wallpaper2".source = "${wallpaper_src}/city_sunset_v.jpg";

  xsession.windowManager.i3.config.startup = lib.mkMerge [
    # Monitor layout first, before the bar and compositor start.
    (lib.mkBefore [
      {
        command = "xrandr --output <OUTPUT-1> --auto --output <OUTPUT-2> --right-of <OUTPUT-1>";
        always = true;
        notification = false;
      }
    ])
    [
      {
        # This requires a delay otherwise the resolution is not set correctly by feh.
        command = "sleep 2 && ${pkgs.feh}/bin/feh --bg-scale ~/.wallpaper1 ~/.wallpaper2";
        always = true;
        notification = false;
      }
    ]
  ];

  # NOTE: Only update it on clean installs.
  home.stateVersion = "26.05";
}
```

Find the monitor names (`DP-1`, `HDMI-1`, …) with `xrandr --query` once the desktop is running. With a single monitor, drop the xrandr entry and pass one wallpaper to feh.

---

## 3. Register the host

**`flake.nix`:** add the name to the host list:

```nix
nixosConfigurations = nixpkgs.lib.genAttrs [
  "shunya-dsktp"
  "nb250-10n"
  "<name>"
] mkHost;
```

**`.github/workflows/build.yml`:** add it to the CI matrix so every push builds it:

```yaml
matrix:
  hostname:
    - shunya-dsktp
    - nb250-10n
    - <name>
```

**`README.md`:** add a row to the *Current Hosts* table.

---

## 4. Host-specific configuration

Everything below is optional. Pick what the machine needs.

### A package for this machine only

```nix
# hosts/<name>/home.nix: for you
home.packages = with pkgs; [ obs-studio ];

# hosts/<name>/default.nix: system-wide (root, services)
environment.systemPackages = with pkgs; [ smartmontools ];
```

Add `{ pkgs, ... }:` at the top of the file if it isn't there yet.

### Overriding something from the base profile

Lists (packages, firewall ports, groups) simply merge, so add to them. A single value that base already sets needs `lib.mkForce`. For example, a server with a static IP instead of NetworkManager:

```nix
{ lib, ... }:

{
  # ...imports, bootloader, stateVersion...

  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = false; # hardware-configuration.nix enables it with mkDefault
  networking.interfaces.<interface>.ipv4.addresses = [
    {
      address = "192.168.1.20";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" ];
}
```

Find the interface name with `ip link`. If several hosts end up forcing the same value, move that setting out of the shared module instead.

### A feature shared by some hosts

Create a module and import it from each host that needs it. For example, an NVIDIA GPU:

```nix
# modules/nixos/nvidia.nix
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia.open = true; # Turing (GTX 16xx / RTX 20xx) or newer; false for older cards
}
```

```nix
# hosts/<name>/default.nix
imports = [
  ./hardware-configuration.nix
  ../../profiles/desktop-niri.nix
  ../../modules/nixos/nvidia.nix
];
```

### Laptop: Wi-Fi in the status bar

On niri, nothing to do: Waybar's `network` segment shows whichever interface is connected, wired or Wi-Fi.

On i3, Polybar shows the wired interface (`eth`) by default. A laptop can import the unused `wlan` part and override the right side of the bar in its `home.nix`:

```nix
{ lib, ... }:

{
  imports = [ ../../modules/home/desktop/polybar/modules/network/wlan.nix ];

  services.polybar.config."bar/main".modules-right =
    lib.mkForce "memory cpu wlan pulseaudio hostname uname";
}
```

Wi-Fi networks themselves are handled by NetworkManager, which is already in the base profile: use `nmtui` or `nmcli` to connect.

### Homelab service

To self-host something on a server, add a module in `modules/nixos/homelab/` and import it from that host's `default.nix`:

```nix
# modules/nixos/homelab/<service>.nix
{
  imports = [ ./common.nix ];

  # Served by nginx as http://<subdomain>.shunya.lan
  homelab.proxies.<subdomain>.port = 8096;

  virtualisation.oci-containers.containers."<service>" = {
    autoStart = true;
    image = "<image>:<pinned-version>"; # pin a version, never :latest
    ports = [ "127.0.0.1:8096:8096" ]; # localhost only; nginx is the way in
    volumes = [ "<service>:/config" ];
    environment.TZ = "Europe/Madrid";
  };
}
```

- Don't open the service's port in the firewall. `common.nix` opens port 80 for nginx, and nginx forwards to `127.0.0.1`.
- `<subdomain>.shunya.lan` must resolve to **this** server's IP. DNS is handled in OpenWrt, so add the record there. If the domain points at another server, the request lands on the wrong nginx.
- For passwords, see [Secrets](#5-secrets) and the `sops.templates` pattern in `omeka.nix`.

---

## 5. Secrets

Skip this step if the host has no secrets.

Secrets are decrypted on the host with its SSH host key, so sops needs to know that key's public half.

**1. Make sure the host has an SSH host key.** Servers get one from the SSH service, but a fresh install without SSH (and every desktop, which doesn't run SSH) may not have it yet. Generate it on the machine before the first switch:

```bash
sudo ssh-keygen -A   # creates any missing /etc/ssh/ssh_host_*_key
```

**2. Convert it to an age key.** On the machine:

```bash
nix-shell -p ssh-to-age --run 'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
```

Or from your desktop, if the machine accepts SSH:

```bash
ssh-keyscan -t ed25519 <ip-or-name> 2>/dev/null | cut -d' ' -f2- | nix run nixpkgs#ssh-to-age
```

**3. Add it to `/.sops.yaml`**, as a key and a rule for the host's file:

```yaml
keys:
  - &admin age1wy0sv6q4ujx68xctjwd2rhsjazghc00jedy6pscr2lg3gr9ympestgkkny
  - &nb250-10n age14rfzd0avnt3j2rdurpttwkwe35dcfn9a403cnzz6fwjaz9ly2etq0zl439
  - &<name> age1...                                  # new

creation_rules:
  # ...existing rules...
  - path_regex: secrets/<name>\.yaml$                # new
    key_groups:
      - age:
          - *admin
          - *<name>
```

**4. Create the secrets file** from the repository root. It's encrypted for the recipients in the matching rule:

```bash
nix shell nixpkgs#sops -c sops secrets/<name>.yaml
git add secrets/<name>.yaml
```

**5. Use it.** Import `../../secrets` in the host's `default.nix`, then declare and read secrets in the module that needs them:

```nix
sops.secrets."<service>/api_token" = { };
# file path: config.sops.secrets."<service>/api_token".path
```

To change who can decrypt an existing file (a new admin key, a replaced host key), edit `.sops.yaml`, then run `sops updatekeys secrets/<file>.yaml`.

---

## 6. SSH access

**New server.** `modules/nixos/ssh.nix` only allows key login, and only for the keys listed there. Make sure the key of the machine you'll connect from is in that list **before** the first switch. Otherwise password login stops working and you'll need a keyboard on the machine to get back in.

**New desktop.** For the new desktop to reach the servers, add its public key (`~/.ssh/id_ed25519.pub`, generated with `ssh-keygen -t ed25519` if missing) to the list in `ssh.nix`, then redeploy the servers. For it to also edit secrets, add its age key (`ssh-to-age < ~/.ssh/id_ed25519.pub`) as a second admin in `.sops.yaml` and run `sops updatekeys` on every secrets file.

---

## 7. Build and deploy

### Check it builds

Flakes only see files that git tracks, so stage the new files first:

```bash
git add hosts/<name>
nix flake check
nix build .#nixosConfigurations.<name>.config.system.build.toplevel
```

### First switch, on the machine itself

The hardware configuration only exists on the new machine, so the simplest first deploy happens there:

```bash
nix-shell -p git
git clone https://github.com/ItsShunya/nixfiles ~/.nixos
cd ~/.nixos
# create hosts/<name>/ and register it (steps 2–3, plus 4–6 if needed), then:
git add -A
sudo nixos-rebuild switch --flake .#<name> --option experimental-features 'nix-command flakes'
```

- Name the host explicitly (`.#<name>`): until this first switch, the hostname is still the installer's default.
- A fresh install doesn't have flakes enabled; `--option` turns them on for this one command, and the configuration enables them permanently.
- The configuration creates the `shunya` user. Set its password with `sudo passwd shunya` before logging out of the installer's user.

Reboot afterwards, so the new bootloader entry, kernel and services start cleanly. Then commit and push the new host from that machine. Pushing over HTTPS needs a GitHub token there. Alternatively, copy the folder to your desktop (`scp -r <name>:.nixos/hosts/<name> hosts/`) and commit from there.

### Later updates

See [build-and-deploy.md](build-and-deploy.md) for all the options. In short, on the machine:

```bash
cd ~/.nixos && git pull
sudo nixos-rebuild switch --flake .   # the attribute defaults to the hostname
```

Or from your desktop, without a checkout on the server:

```bash
nixos-rebuild switch --flake .#<name> --target-host <name> --sudo --ask-sudo-password
```

---

## Checklist

- [ ] `hosts/<name>/default.nix` imports `hardware-configuration.nix` and one profile
- [ ] Bootloader matches the firmware (UEFI → systemd-boot, BIOS → GRUB with a `/dev/disk/by-id` device)
- [ ] `system.stateVersion` and `home.stateVersion` set to the release the machine was installed with
- [ ] Name added to `flake.nix`, `build.yml` and the README host table
- [ ] New files staged with `git add` before building
- [ ] Server: the key you connect with is in `modules/nixos/ssh.nix`
- [ ] Secrets: host key generated, added to `.sops.yaml`, `secrets/<name>.yaml` created, `../../secrets` imported
- [ ] Homelab: DNS for the new subdomains points at this server
- [ ] After the first switch: `sudo passwd shunya`, reboot, commit and push
