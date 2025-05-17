{
  lib,
  pkgs,
  fetchFromSourcehut,
  ...
}:

let
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "pinenote-dist";
    rev = "81a8ea7faa40b3731e4aa83034250862f4e698d6";
    hash = "sha256-6yhPQ25Grgyazx1Dob/jwD06dVg2JUdh/tFjsk8mtt4=";
  };

  wbf_to_custom =
    pkgs.writers.writePython3Bin "wbf_to_custom.py"
      {
        libraries = with pkgs.python3Packages; [
          numpy
          pandas
        ];
        doCheck = false;
      }
      ''
        import sys
        sys.path.insert(0, "${src}/bin")
        import wbf_to_custom

        if __name__ == "__main__":
            sys.exit(wbf_to_custom.main() if hasattr(wbf_to_custom, "main") else None)
      '';
in

pkgs.stdenvNoCC.mkDerivation {
  pname = "pinenote-waveform-tools";
  version = "2025.04.29";

  inherit src;
  dontBuild = true;

  installPhase = ''
    substituteInPlace bin/waveform_extract.sh \
      --replace "hexdump" "${pkgs.util-linux}/bin/hexdump"
    sed -i 's#/usr/lib/#/lib/#' bin/waveform_extract.sh

    install -Dm755 bin/waveform_extract.sh -t $out/usr/bin
    install -Dm755 ${wbf_to_custom}/bin/wbf_to_custom.py -t $out/usr/bin
  '';

  meta = with lib; {
    description = "Scripts used for extracting and converting the waveform partition to be used by rockchip_ebc.";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.gpl3Only;
  };
}
