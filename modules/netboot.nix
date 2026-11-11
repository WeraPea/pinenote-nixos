# adapted from nixpkgs netboot
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.pinenote.netboot;
in
{
  options = {
    pinenote.netboot.enable = lib.mkEnableOption "booting over usb using netboot";
    pinenote.netboot.storeContents = lib.mkOption {
      type = lib.types.listOf lib.types.pathInStore;
      example = lib.literalExpression "[ pkgs.stdenv ]";
      description = ''
        This option lists additional derivations to be included in the
        Nix store in the generated netboot image.
      '';
    };
    pinenote.netboot.squashfsPkgs = lib.mkOption {
      type = lib.types.pkgs;
      default = pkgs;
      defaultText = lib.literalExpression "pkgs";
      example = lib.literalExpression ''import nixpkgs { system = "x86_64-linux"; }'';
      description = ''
        nixpkgs instance used for building the squashfsStore image,
        as opposed to the instance used for the store paths in it.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    pinenote.netboot.storeContents = [ config.system.build.toplevel ];

    system.build.squashfsStore =
      cfg.squashfsPkgs.callPackage "${cfg.squashfsPkgs.path}/nixos/lib/make-squashfs.nix"
        { inherit (cfg) storeContents; };

    boot.initrd.compressorArgs = [ "-19" ]; # helps fit in fastboot stage size limit
    boot.initrd.availableKernelModules = [
      "nbd"
      "squashfs"
      "overlay"
      "libcomposite"
      "usb_f_ncm"
      "u_ether"
      "phy_rockchip_inno_usb2"
      "wusb3801"
    ];
    boot.initrd.kernelModules = [
      "libcomposite"
    ];
    boot.initrd.systemd.storePaths = [ pkgs.nbd ];

    boot.initrd.systemd.network = {
      enable = true;
      networks."10-usb" = {
        matchConfig.Name = "usb0";
        address = [ "10.55.0.2/24" ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCPServer = true;
        };
        dhcpServerConfig = {
          PersistLeases = "runtime";
          PoolOffset = 1; # 10.55.0.1
          PoolSize = 1;
          EmitRouter = false;
          EmitDNS = false;
          DefaultLeaseTimeSec = "7d";
          MaxLeaseTimeSec = "7d";
        };
      };
    };

    boot.initrd.systemd.services.usb-network-gadget = {
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-modules-load.service" ];
      before = [ "systemd-networkd.service" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        g=/sys/kernel/config/usb_gadget/netboot
        mkdir -p $g/strings/0x409 $g/configs/c.1 $g/functions/ncm.usb0
        echo 0x1d6b > $g/idVendor
        echo 0x0104 > $g/idProduct
        echo netboot > $g/strings/0x409/product
        ln -s $g/functions/ncm.usb0 $g/configs/c.1/
        until [ -n "$(ls /sys/class/udc)" ]; do sleep 0.5; done
        ls /sys/class/udc | head -n1 > $g/UDC
      '';
    };

    boot.initrd.systemd.services.nbd-store = {
      wantedBy = [ "initrd.target" ];
      after = [
        "systemd-modules-load.service"
        "systemd-networkd.service"
        "usb-network-gadget.service"
      ];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        export PATH="${lib.makeBinPath [ pkgs.nbd ]}:$PATH"
        until nbd-client 10.55.0.1 10809 /dev/nbd0; do sleep 2; done
      '';
    };

    systemd.services.register-nix-paths = {
      description = "Register Nix Store Paths";
      unitConfig.DefaultDependencies = false;
      wantedBy = [ "sysinit.target" ];
      before = [
        "sysinit.target"
        "shutdown.target"
        "nix-daemon.socket"
        "nix-daemon.service"
      ];
      after = [ "local-fs.target" ];
      conflicts = [ "shutdown.target" ];
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        # After booting, register the contents of the Nix store
        # in the Nix database in the tmpfs.
        ${lib.getExe' config.nix.package "nix-store"} --load-db < /nix/store/nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${lib.getExe' config.nix.package "nix-env"} -p /nix/var/nix/profiles/system --set /run/current-system
      '';
    };

    fileSystems."/" = lib.mkForce {
      fsType = "tmpfs";
      options = [ "mode=0755" ];
    };
    fileSystems."/nix/.ro-store" = lib.mkForce {
      device = "/dev/nbd0";
      fsType = "squashfs";
      neededForBoot = true;
    };
    fileSystems."/nix/.rw-store" = lib.mkForce {
      fsType = "tmpfs";
      neededForBoot = true;
      options = [ "mode=0755" ];
    };
    fileSystems."/nix/store" = lib.mkForce {
      neededForBoot = true;
      overlay = {
        lowerdir = [ "/nix/.ro-store" ];
        upperdir = "/nix/.rw-store/store";
        workdir = "/nix/.rw-store/work";
      };
    };
  };
}
