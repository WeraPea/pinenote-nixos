{
  lib,
  pkgs,
  fetchFromSourcehut,
  ...
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "waveform_extract";
  version = "unstable-2025-04-29";
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "pinenote-dist";
    rev = "81a8ea7faa40b3731e4aa83034250862f4e698d6";
    hash = "sha256-6yhPQ25Grgyazx1Dob/jwD06dVg2JUdh/tFjsk8mtt4=";
  };
  nativeBuildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    sed -i 's#/usr/lib/#/lib/#' bin/waveform_extract.sh
    install -Dm755 bin/waveform_extract.sh -t $out/bin
    wrapProgram $out/bin/waveform_extract.sh \
      --prefix PATH : ${pkgs.coreutils}/bin:${pkgs.util-linux}/bin
  '';
  meta = with lib; {
    description = "Extraction of waveform partition to /lib/firmware/rockchip/ebc.wbf";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.gpl3Only;
  };
}
