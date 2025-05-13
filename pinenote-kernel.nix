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
  ignoreConfigErrors = true; # from jzbor/nix-parcels
  # enableCommonConfig = false; # maybe lower size?
  extraConfig = ''
    VIDEO_THP7312 n
    CRYPTO_AEGIS128_SIMD n
    ROCKCHIP_DW_HDMI_QP n
  ''; # fails to build otherwise
}).overrideAttrs
  (oldAttrs: {
    postInstall = ''
      cp "$out/dtbs/rockchip/rk3566-pinenote-v1.2.dtb" "$out/dtbs/rockchip/pn.dtb"
      ${oldAttrs.postInstall}
    '';
  })
