{
  pkgs,
  lib,
  outputs,
  ...
}:
{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackagesFor (outputs.packages.${pkgs.system}.pinenote-kernel);
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
  networking.hostName = "pinenote";

  # hardware.deviceTree.name = "rockchip/rk3566-pinenote-v1.2.dtb";
  hardware.deviceTree.name = "rockchip/pn.dtb"; # workaround: current uboot has a 127 char limit for the path
  hardware.firmware = [
    outputs.packages.${pkgs.system}.pinenote-firmware
    pkgs.raspberrypiWirelessFirmware
  ];
}
