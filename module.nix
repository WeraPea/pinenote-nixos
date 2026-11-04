inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  packages = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options = {
    pinenote.config.enable = lib.mkEnableOption "pinenote specific nixos configs";
    pinenote.sway-dbus-integration.enable = lib.mkEnableOption "sway-dbus-integration service";
    pinenote.pinenote-service.enable = lib.mkEnableOption "pinenote-service";
    pinenote.pinenote-service.package = lib.mkPackageOption packages "pinenote-service" { };
    pinenote.usb-boot.enable = lib.mkEnableOption "booting from usb (see usb-helper)";
  };
  config = lib.mkIf config.pinenote.config.enable {
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
    boot.kernelPackages = lib.mkDefault (pkgs.linuxPackagesFor (packages.pinenote-kernel));
    boot.initrd.systemd.tpm2.enable = false;
    boot.initrd.includeDefaultModules = false;
    boot.initrd.availableKernelModules = [
      "gpio-rockchip"
      "ext4"
      "mmc_block"
      "usbhid"
      "hid_generic"
    ]
    ++ lib.optionals config.pinenote.usb-boot.enable [
      "usb_storage"
      "uas"
      "scsi_mod"
      "sd_mod"
      "phy_rockchip_inno_usb2"
      "wusb3801"
    ];

    boot.kernelParams = [
      "console=tty0"
      "console=ttyS2,1500000n8"
      "earlycon"
      "ignore_loglevel"
      "vt.global_cursor_default=0"
    ]
    ++ lib.optionals config.pinenote.usb-boot.enable [
      "rootwait"
    ];

    systemd.user.services.sway-dbus-integration =
      lib.mkIf config.pinenote.sway-dbus-integration.enable
        {
          description = "sway-dbus-integration";
          wantedBy = [ "graphical-session.target" ];
          wants = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${lib.getExe' packages.sway-dbus-integration "sway_dbus_integration"}";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
    systemd.services.setup-waveform = {
      description = "setup rockchip_ebc waveform files";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe packages.setup-waveform;
      };
    };
    systemd.packages = lib.mkIf config.pinenote.pinenote-service.enable [
      config.pinenote.pinenote-service.package
    ];
    services.dbus.packages = lib.mkIf config.pinenote.pinenote-service.enable [
      config.pinenote.pinenote-service.package
    ];

    # hardware.deviceTree.name = "rockchip/rk3566-pinenote-v1.2.dtb";
    hardware.deviceTree.name = "rockchip/pn.dtb"; # workaround: current uboot has a 127 char limit for the path
    hardware.firmware = [
      packages.pinenote-firmware
      pkgs.raspberrypiWirelessFirmware
    ];
  };
}
