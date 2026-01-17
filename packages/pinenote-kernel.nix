{
  lib,
  buildLinux,
  fetchFromSourcehut,
  structuredExtraConfig ? { },
  argsOverride ? { },
  ...
}@args:
let
  version = "6.19.0-rc1";
in
(buildLinux (
  args
  // {
    src = fetchFromSourcehut {
      owner = "~hrdl";
      repo = "linux";
      rev = "6515b53ee928ed7cd03b0e6660575d70a5fc422e";
      hash = "sha256-637dNW+6cPaaJ3KA/rqdc0xQ9s+cMKXG9Jt10U54TuY=";
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
