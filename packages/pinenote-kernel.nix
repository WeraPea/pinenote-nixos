{
  lib,
  buildLinux,
  fetchFromSourcehut,
  structuredExtraConfig ? { },
  argsOverride ? { },
  ...
}@args:
let
  version = "6.19.0";
in
(buildLinux (
  args
  // {
    src = fetchFromSourcehut {
      owner = "~hrdl";
      repo = "linux";
      rev = "46028a0e2658877625568f2134e243b304966ef4";
      hash = "sha256-Y96Yae3SLoTJoRLqjeMK7lubBCsJUrc/1Lk6Eyfm6K0=";
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
