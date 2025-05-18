inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    pinenote-config.enable = lib.mkEnableOption "Enable pinenote specific nixos config";
  };
  config = lib.mkIf config.pinenote-config.enable {
    services.udev.packages = [
      (pkgs.writeTextDir "lib/udev/rules.d/81-libinput-pinenote.rules" ''
        ACTION=="remove", GOTO="libinput_device_group_end"
        KERNEL!="event[0-9]*", GOTO="libinput_device_group_end"

        ATTRS{phys}=="?*", ATTRS{name}=="cyttsp5", ENV{LIBINPUT_DEVICE_GROUP}="pinenotetouch"
        ATTRS{phys}=="?*", ATTRS{name}=="w9013 2D1F:0095 Stylus", ENV{LIBINPUT_DEVICE_GROUP}="pinenotetouch"
        #ATTRS{phys}=="?*", ATTRS{name}=="w9013 2D1F:0095 Stylus", ENV{ID_INPUT_HEIGHT_MM}=""
        #ATTRS{phys}=="?*", ATTRS{name}=="w9013 2D1F:0095 Stylus", ENV{ID_INPUT_WIDTH_MM}=""
        #ATTRS{phys}=="?*", ATTRS{name}=="cyttsp5", PROGRAM=="/usr/local/bin/is_smaeul_kernel", ENV{LIBINPUT_CALIBRATION_MATRIX}="-1 0 1 0 -1 1"
        ATTRS{phys}=="?*", ATTRS{name}=="cyttsp5", ENV{LIBINPUT_CALIBRATION_MATRIX}="-1 0 1 0 -1 1"

        LABEL="libinput_device_group_end"
      '')
      (pkgs.writeTextDir "lib/udev/rules.d/83-backlight.rules" ''
        SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      '')
      (pkgs.writeTextDir "lib/udev/rules.d/84-rockchip-ebc-power.rules" ''
        DRIVER=="rockchip-ebc", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/%p/power/control", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/%p/power/control"
      '')
    ];
    environment.etc."libinput/local-overrides.quirks".text = ''
      [PineNote]
      MatchName=cyttsp5
      AttrPalmPressureThreshold=27
      AttrThumbPressureThreshold=28
      AttrSizeHint=210x157
      #AttrResolutionHint=4x4
      #AttrPalmSizeThreshold=1
    '';
    boot.extraModprobeConfig = ''
      options rockchip_ebc dithering_method=2 default_hint=0xa0 early_cancellation_addition=2 redraw_delay=200
      options brcmfmac feature_disable=0x82000
    '';
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    boot.kernelPackages = pkgs.linuxPackagesFor (inputs.self.packages.${pkgs.system}.pinenote-kernel);
    boot.initrd.availableKernelModules = lib.mkForce [
      # how could mkForce be removed?
      "gpio-rockchip"
      "ext4"
      "mmc_block"
      "usbhid"
      "hid_generic"
    ];

    # hardware.deviceTree.name = "rockchip/rk3566-pinenote-v1.2.dtb";
    hardware.deviceTree.name = "rockchip/pn.dtb"; # workaround: current uboot has a 127 char limit for the path
    hardware.firmware = [
      inputs.self.packages.${pkgs.system}.pinenote-firmware
      pkgs.raspberrypiWirelessFirmware
    ];
    environment.defaultPackages =
      let
        tools = inputs.self.packages.${pkgs.system}.pinenote-waveform-tools;
      in
      [
        (pkgs.writeShellScriptBin "setup-waveform.sh" ''
          if [ "$EUID" -ne 0 ]
            then echo "Please run as root"
            exit
          fi
          test -e /lib/firmware/rockchip_ebc/ebc.wbf && exit
          test -e /lib/firmware/rockchip_ebc/custom_wf.bin && exit
          mkdir -p /lib/firmware/rockchip
          ${tools}/usr/bin/waveform_extract.sh
          cd /tmp && ${tools}/usr/bin/wbf_to_custom.py /lib/firmware/rockchip/ebc.wbf && mv custom_wf.bin /lib/firmware/rockchip/custom_wf.bin && (modprobe -r rockchip_ebc; modprobe rockchip_ebc)
        '') # don't know how or if even possible to handle the waveform partition more "nix" way
      ];
  };
}
