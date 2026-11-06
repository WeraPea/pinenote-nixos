{
  lib,
  stdenvNoCC,
  runtimeShell,
  writeText,
  waveform-extract,
  wbf-to-custom,
  kmod,
}:
let
  script = writeText "setup-waveform.sh" /* bash */ ''
    #!${runtimeShell}
    export PATH="${
      lib.makeBinPath [
        kmod
        waveform-extract
        wbf-to-custom
      ]
    }:$PATH"
    if [ "$EUID" -ne 0 ]
      then echo "Please run as root"
      exit
    fi
    test -e /lib/firmware/rockchip/custom_wf.bin && exit
    test -e /lib/firmware/rockchip/ebc.wbf || {
      mkdir -p /lib/firmware/rockchip
      waveform_extract.sh
    }
    cd /tmp && wbf_to_custom /lib/firmware/rockchip/ebc.wbf && mv custom_wf.bin /lib/firmware/rockchip/custom_wf.bin && (modprobe -r rockchip_ebc; modprobe rockchip_ebc)
  '';
in
stdenvNoCC.mkDerivation {
  pname = "setup-waveform";
  version = "1.0";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 ${script} $out/bin/setup-waveform
    runHook postInstall
  '';

  meta = {
    description = "Extracts the PineNote's waveform and converts it for rockchip_ebc, then reloads the rockchip_ebc module";
    mainProgram = "setup-waveform";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
  };
}
