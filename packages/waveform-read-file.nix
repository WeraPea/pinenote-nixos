{
  lib,
  pkgs,
  fetchFromSourcehut,
  ...
}:
pkgs.python3Packages.buildPythonPackage {
  pname = "waveform-read-file";
  version = "unstable-2025-04-29";
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "pinenote-dist";
    rev = "81a8ea7faa40b3731e4aa83034250862f4e698d6";
    hash = "sha256-6yhPQ25Grgyazx1Dob/jwD06dVg2JUdh/tFjsk8mtt4=";
  };
  pyproject = true;
  build-system = with pkgs.python3Packages; [ setuptools ];
  sourceRoot = "source/bin";
  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup
    setup(
      name='read_file',
      py_modules=['read_file'],
      version='2025.04.29',
    )
    EOF
  '';
  meta = with lib; {
    description = "Waveform file reader.";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.mit;
  };
}
