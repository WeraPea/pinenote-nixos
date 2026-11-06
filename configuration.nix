{
  lib,
  inputs,
  outputs,
  cross,
  usb,
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
  pinenote.usb-boot.enable = usb;
  fileSystems."/" = {
    label = if usb then "nixos-usb" else "nixos";
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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = lib.mkIf cross (pkgsCross.linuxPackagesFor (packagesCross.pinenote-kernel));
}
