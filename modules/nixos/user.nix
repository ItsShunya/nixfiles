{ pkgs, ... }:

{
  # The only user account. Host roles add groups and packages on top.
  users.users.shunya = {
    isNormalUser = true;
    description = "Shunya";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    useDefaultShell = true;
    packages = with pkgs; [
      neovim
    ];
  };
}
