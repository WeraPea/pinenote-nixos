## pinenote-firmware
PineNote firmware
- Version: `0.2`
- [Homepage](https://gitlab.com/kernel-firmware/linux-firmware)
- [Homepage](https://github.com/RPi-Distro/firmware-nonfree)
- Source: [packages/pinenote-firmware.nix:48](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/pinenote-firmware.nix#L48)
- Licence: `unfreeRedistributableFirmware`

## pinenote-kernel
Linux kernel, with PineNote-related modifications
- Version: `6.19.0`
- [Homepage](https://git.sr.ht/~hrdl/linux)
- Source: [packages/pinenote-kernel.nix:21](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/pinenote-kernel.nix#L21)
- Licence: `gpl2Only`

## pinenote-service
PineNote Service aims to be a central, dbus-aware service to manage various PineNote specific configurations.
- Version: `1.0.1`
- [Homepage](https://git.sr.ht/~phantomas/pinenote-service/)
- Source: [packages/pinenote-service.nix:29](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/pinenote-service.nix#L29)
- Licence: `gpl3Plus`

## read-file
Waveform file reader.
- Version: `unstable-2025-04-29`
- [Homepage](https://git.sr.ht/~hrdl/pinenote-dist)
- Source: [packages/read-file.nix:30](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/read-file.nix#L30)
- Licence: `mit`

## rockchip-ebc-custom-ioctl
Ioctl for rockchip_ebc.
- Version: `unstable-2025-05-06`
- [Homepage](https://git.sr.ht/~hrdl/pinenote-dist)
- Source: [packages/rockchip-ebc-custom-ioctl.nix:30](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/rockchip-ebc-custom-ioctl.nix#L30)
- Licence: `gpl3Only`

## setup-waveform
Extracts the PineNote's waveform and converts it for rockchip_ebc, then reloads the rockchip_ebc module
- Version: `1.0`
- Source: [packages/setup-waveform.nix:46](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/setup-waveform.nix#L46)
- Licence: `gpl3Only`

## sway-dbus-integration
Integration of sway and waybar with rockchip_ebc.
- Version: `unstable-2025-05-01`
- [Homepage](https://git.sr.ht/~hrdl/pinenote-dist)
- Source: [packages/sway-dbus-integration.nix:59](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/sway-dbus-integration.nix#L59)
- Licence: `gpl3Only`

## usb-helper
Stages a NixOS kernel, initrd and dtb onto a PineNote over fastboot and prints the U-Boot commands to boot it from a USB stick or netboot
- Version: `1.0`
- Source: [packages/usb-helper.nix:176](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/usb-helper.nix#L176)
- Licence: `gpl3Only`

## waveform-extract
Extraction of waveform partition to /lib/firmware/rockchip/ebc.wbf
- Version: `unstable-2025-04-29`
- [Homepage](https://git.sr.ht/~hrdl/pinenote-dist)
- Source: [packages/waveform-extract.nix:25](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/waveform-extract.nix#L25)
- Licence: `gpl3Only`

## wbf-to-custom
Conversion script of wbf to custom format.
- Version: `unstable-2025-04-29`
- [Homepage](https://git.sr.ht/~hrdl/pinenote-dist)
- Source: [packages/wbf-to-custom.nix:47](https://github.com/WeraPea/pinenote-nixos/blob/main/packages/wbf-to-custom.nix#L47)
- Licence: `gpl3Only`
