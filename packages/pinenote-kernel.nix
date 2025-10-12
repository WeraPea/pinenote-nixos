{
  lib,
  buildLinux,
  fetchFromSourcehut,
  structuredExtraConfig ? { },
  argsOverride ? { },
  ...
}@args:
let
  version = "6.17.0-rc5";
in
(buildLinux (
  args
  // {
    src = fetchFromSourcehut {
      owner = "~hrdl";
      repo = "linux";
      rev = "1a119bb3028b09cab962781aa3b6992ed7a3aa1e";
      sha256 = "sha256-UKwjXJ5CyUoGpiNkyYl/2sg7E3Iw8Lsv5/1IJkdbvAo=";
    };
    inherit version;
    modDirVersion = version;
    defconfig = "pinenote_defconfig";
    ignoreConfigErrors = true;
    structuredExtraConfig =
      with lib.kernel;
      {
        VIDEO_THP7312 = no;
        CRYPTO_AEGIS128_SIMD = no;
        ROCKCHIP_DW_HDMI_QP = lib.mkForce no;
      }
      // structuredExtraConfig;
  }
  // argsOverride
)).overrideAttrs
  (oldAttrs: {
    postInstall = ''
      cp "$out/dtbs/rockchip/rk3566-pinenote-v1.2.dtb" "$out/dtbs/rockchip/pn.dtb"
      ${oldAttrs.postInstall}
    '';
  })
