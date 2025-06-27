{
  pkgs,
  fetchFromSourcehut,
  ...
}:
(pkgs.buildLinux {
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "linux";
    rev = "f75fe16d81ae784b8cd2b915113f3a99ff812777";
    sha256 = "sha256-DhMiZMcwownJJRqIYOj87E/j34jJZb2/rTOhYuMumG4=";
  };
  version = "6.15.0-rc3";
  modDirVersion = "6.15.0-rc3";
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
