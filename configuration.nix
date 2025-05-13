{
  pkgs,
  lib,
  pkgsCross,
  ...
}:
{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.callPackage ./pinenote-kernel.nix { pkgs = pkgsCross; }
  );
  boot.initrd.availableKernelModules = lib.mkForce [
    "gpio-rockchip" # needed for boot
    "ext2"
    "ext4"
    "ahci"
    "sd_mod"
    "sr_mod"
    "mmc_block"
    "ehci_hcd"
    "ehci_pci"
    "ohci_hcd"
    "ohci_pci"
    "xhci_hcd"
    "xhci_pci"
    "usbhid"
    "hid_generic"
    "hid_microsoft"
  ]; # TODO: trim this as you already remove stuff anyways
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

  # hardware.deviceTree.name = "rockchip/rk3566-pinenote-v1.2.dtb";
  hardware.deviceTree.name = "rockchip/pn.dtb"; # workaround: uboot has a 127 char limit for the path
  hardware.firmware = [
    (pkgs.callPackage ./pinenote-firmware.nix { })
    pkgs.raspberrypiWirelessFirmware
  ];
}
