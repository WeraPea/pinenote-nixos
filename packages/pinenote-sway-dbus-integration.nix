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

  sway_dbus_integration =
    pkgs.writers.writePython3Bin "sway_dbus_integration.py"
      {
        libraries = with pkgs.python3Packages; [
          dbus-next
          i3ipc
          numpy
        ];
        doCheck = false;
      }
      ''
        import sys
        sys.path.insert(0, "${src}/bin")
        import sway_dbus_integration
        import asyncio

        if __name__ == "__main__":
            if hasattr(sway_dbus_integration, "main"):
                sys.exit(asyncio.run(sway_dbus_integration.main()))
      '';
in

pkgs.stdenvNoCC.mkDerivation {
  pname = "pinenote-sway-dbus-integration";
  version = "2025.05.06";

  inherit src;
  dontBuild = true;

  installPhase = ''
    install -Dm755 ${sway_dbus_integration}/bin/sway_dbus_integration.py -t $out/usr/bin
  '';

  meta = with lib; {
    description = "Integraion of sway and waybar with rockchip_ctl.";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.gpl3Only;
  };
}
