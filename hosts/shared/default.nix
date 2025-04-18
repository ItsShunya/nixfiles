{ config, pkgs, ... }:

{
   # Bootloader.
   boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
   };

   # Enable networking
   networking.networkmanager.enable = true;

   # Set your time zone.
   time.timeZone = "Europe/Madrid";

   # Select internationalisation properties.
   i18n.defaultLocale = "en_GB.UTF-8";

   i18n.extraLocaleSettings = {
     LC_ADDRESS = "es_ES.UTF-8";
     LC_IDENTIFICATION = "es_ES.UTF-8";
     LC_MEASUREMENT = "es_ES.UTF-8";
     LC_MONETARY = "es_ES.UTF-8";
     LC_NAME = "es_ES.UTF-8";
     LC_NUMERIC = "es_ES.UTF-8";
     LC_PAPER = "es_ES.UTF-8";
     LC_TELEPHONE = "es_ES.UTF-8";
     LC_TIME = "es_ES.UTF-8";
   };

   # Configure console keymap
   console.keyMap = "es";

   # Enable CUPS to print documents.
   services.printing.enable = true;

   # Enable sound with pipewire.
   hardware.pulseaudio.enable = false;
   security.rtkit.enable = true;
   services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
     # If you want to use JACK applications, uncomment this
     #jack.enable = true;
     #media-session.enable = true;
   };

   # Install Firefox.
   programs.firefox.enable = true;

   # Set Zsh as default shell.
   programs.zsh.enable = true;
   environment.shells = with pkgs; [ 
      zsh 
   ];
   users.defaultUserShell = pkgs.zsh;

   # Allow unfree packages
   nixpkgs.config.allowUnfree = true;

   # List packages installed in system profile. To search, run:
   # $ nix search wget
   environment.systemPackages = with pkgs; [
      git     
      wget
      wezterm
      neovim
      python3
   ];

   nix = {

     settings = {
       experimental-features = [ "nix-command" "flakes" ]; # Enable flakes.
       trusted-users = [ "root" "@wheel" ];
       warn-dirty = false;

       # Optimize storage.
       # You can also manually optimize the store via:
       #    nix-store --optimise
       # Refer to the following link for more details:
       # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
       auto-optimise-store = true;
     };

     # Perform garbage collection weekly to maintain low disk usage.
     gc = {
       automatic = true;
       dates = "weekly";
       options = "--delete-older-than 1w";
     };

     optimise.automatic = true;
  };

  system = {
    # Avoid symlink of configuration.nix.
    copySystemConfiguration = false;
  };

}
