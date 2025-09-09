{
  pkgs,
  fetchFromSourcehut,
  ...
}:
(pkgs.buildLinux rec {
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "linux";
    rev = "1a119bb3028b09cab962781aa3b6992ed7a3aa1e";
    sha256 = "sha256-UKwjXJ5CyUoGpiNkyYl/2sg7E3Iw8Lsv5/1IJkdbvAo=";
  };
  version = "6.17.0-rc5";
  modDirVersion = version;
  defconfig = "pinenote_defconfig";
  ignoreConfigErrors = true; # from jzbor/nix-parcels
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
