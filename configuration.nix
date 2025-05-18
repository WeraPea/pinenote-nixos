{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  imports = [ outputs.nixosModules.default ];
  pinenote-config.enable = true;
  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };
  services.openssh = {
    enable = true;
  };
  users.users."user" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # password = "password"; # for boot image only
  };

  networking.networkmanager.enable = true;
  networking.hostName = "pinenote";
}
