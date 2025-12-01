{
  lib,
  rustPlatform,
  fetchFromSourcehut,
}:

rustPlatform.buildRustPackage rec {
  pname = "pinenote-service";
  version = "1.0.1";

  src = fetchFromSourcehut {
    owner = "~phantomas";
    repo = "pinenote-service";
    rev = "v${version}";
    hash = "sha256-+F84gKDexWL9AcTFEj/JVJSdmT9o+6/ahogniz7N/lg=";
  };

  cargoHash = "sha256-A/EzXV3qSSBIyXe0R6XBzCXiuNJgFSS8VRDcDZIq5WQ=";

  postInstall = ''
    substituteInPlace packaging/resources/pinenote.service packaging/resources/org.pinenote.PineNoteCtl.service \
      --replace-fail '/usr/bin/pinenote-service' "$out/bin/pinenote-service"

    install -Dm644 packaging/resources/pinenote.service -t $out/lib/systemd/user/
    install -Dm644 packaging/resources/org.pinenote.PineNoteCtl.service -t $out/share/dbus-1/services/
  '';

  meta = {
    description = "";
    homepage = "https://git.sr.ht/~phantomas/pinenote-service/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pinenote-service";
  };
}
