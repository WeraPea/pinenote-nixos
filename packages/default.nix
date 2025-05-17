{ pkgs, pkgsCross }:
{
  pinenote-kernel = pkgs.callPackage ./pinenote-kernel.nix { pkgs = pkgsCross; };
  pinenote-firmware = pkgs.callPackage ./pinenote-firmware.nix { };
  pinenote-waveform-tools = pkgs.callPackage ./pinenote-waveform-tools.nix { };
}
