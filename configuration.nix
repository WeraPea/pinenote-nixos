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
    "ext2"
    "ext4"
    "ahci"
    "sata_nv"
    "sata_via"
    "sata_sis"
    "sata_uli"
    "ata_piix"
    "pata_marvell"
    "nvme"
    "sd_mod"
    "sr_mod"
    "mmc_block"
    "uhci_hcd"
    "ehci_hcd"
    "ehci_pci"
    "ohci_hcd"
    "ohci_pci"
    "xhci_hcd"
    "xhci_pci"
    "usbhid"
    "hid_generic"
    # "hid_lenovo" # not available even with CONFIG_HID_LENOVO?
    "hid_apple"
    "hid_roccat"
    "hid_logitech_hidpp"
    "hid_logitech_dj"
    "hid_microsoft"
    "hid_cherry"
    "hid_corsair"
  ]; # afaik there is no way in nix to remove a value from this when it is set elsewhere
  # hardware.enableAllFirmware = false;
  # hardware.enableAllHardware = false;
  fileSystems."/" = {
    device = "/dev/mmcblk0p9";
    fsType = "ext4";
  };
  services.openssh = {
    enable = true;
  };

  # hardware.deviceTree.name = "rockchip/rk3566-pinenote-v1.2.dtb";
  hardware.deviceTree.name = "rockchip/pn.dtb"; # workaround: path too long (127 char limit) otherwise, manually copy it over
  networking.useDHCP = true;
  hardware.enableRedistributableFirmware = false;
  hardware.firmware = [ (pkgs.callPackage ./brcm-firmware-pinenote.nix { }) ];
}
