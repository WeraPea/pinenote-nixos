pkgs: rec {
  pinenote-kernel = pkgs.callPackage ./pinenote-kernel.nix { };
  pinenote-firmware = pkgs.callPackage ./pinenote-firmware.nix { };
  rockchip-ebc-custom-ioctl = pkgs.callPackage ./rockchip-ebc-custom-ioctl.nix { };
  pinenote-sway-dbus-integration = pkgs.callPackage ./sway-dbus-integration.nix {
    inherit rockchip-ebc-custom-ioctl;
  };
  waveform-extract = pkgs.callPackage ./waveform-extract.nix { };
  waveform-read-file = pkgs.callPackage ./waveform-read-file.nix { };
  wbf-to-custom = pkgs.callPackage ./wbf-to-custom.nix { inherit waveform-read-file; };
  pinenote-service = pkgs.callPackage ./pinenote-service.nix { };
}
