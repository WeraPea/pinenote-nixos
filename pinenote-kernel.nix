# no real idea what i am doing here
{
  pkgs,
  fetchFromSourcehut,
  ...
}:
(pkgs.buildLinux {
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "linux";
    rev = "b0e82d0f7a25ffa9da40f5d1aa4218023dbfc14d";
    sha256 = "sha256-aenAQqw4ABaXtXM3fnXIg8rBXMqQ5M7eMYmEL1yCB7c=";
  };
  version = "6.15.0-rc3";
  modDirVersion = "6.15.0-rc3";
  defconfig = "pinenote_defconfig";
  ignoreConfigErrors = true;
  enableCommonConfig = false;
  extraConfig = ''
    VIDEO_THP7312 n
    CRYPTO_AEGIS128_SIMD n
  ''; # fails to build without
}).overrideAttrs
  {
    # buildFlags = "KBUILD_BUILD_VERSION=1-NixOS Image vmlinux modules rockchip/rk3566-pinenote-v1.{1,2}.dtb DTC_FLAGS=-@";
  }
