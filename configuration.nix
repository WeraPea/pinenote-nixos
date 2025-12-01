{
  pkgs,
  lib,
  inputs,
  outputs,
  cross,
  ...
}:
let
  pkgsCross = import inputs.nixpkgs {
    system = "x86_64-linux";
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  };
  packagesCross = import ./packages pkgsCross;
in
{
  imports = [ outputs.nixosModules.default ];
  pinenote.config.enable = true;
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
    password = "password";
  };

  networking.networkmanager.enable = true;
  networking.hostName = "pinenote";

  boot.kernelPackages = lib.mkIf cross (pkgsCross.linuxPackagesFor (packagesCross.pinenote-kernel));
}
