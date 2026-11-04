{
  lib,
  writeShellScriptBin,
  waveform-extract,
  wbf-to-custom,
  kmod,
}:
writeShellScriptBin "setup-waveform" ''
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
''
