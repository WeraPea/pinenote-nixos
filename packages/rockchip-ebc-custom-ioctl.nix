{
  lib,
  pkgs,
  fetchFromSourcehut,
  ...
}:
pkgs.python3Packages.buildPythonPackage {
  pname = "rockchip-ebc-custom-ioctl";
  version = "unstable-2025-05-06";
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "pinenote-dist";
    rev = "81a8ea7faa40b3731e4aa83034250862f4e698d6";
    hash = "sha256-6yhPQ25Grgyazx1Dob/jwD06dVg2JUdh/tFjsk8mtt4=";
  };
  sourceRoot = "source/bin";
  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup
    setup(
      name='rockchip_ebc_custom_ioctl',
      py_modules=['rockchip_ebc_custom_ioctl'],
      version='2025.05.06',
    )
    EOF
  '';
  meta = with lib; {
    description = "Ioctl for rockchip_ebc.";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.gpl3Only;
  };
}
