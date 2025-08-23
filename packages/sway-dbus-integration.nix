{
  lib,
  pkgs,
  fetchFromSourcehut,
  rockchip-ebc-custom-ioctl,
  ...
}:

pkgs.python3Packages.buildPythonPackage {
  pname = "pinenote-sway-dbus-integration";
  version = "unstable-2025-05-01";
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "pinenote-dist";
    rev = "81a8ea7faa40b3731e4aa83034250862f4e698d6";
    hash = "sha256-6yhPQ25Grgyazx1Dob/jwD06dVg2JUdh/tFjsk8mtt4=";
  };
  pyproject = true;
  build-system = with pkgs.python3Packages; [ setuptools ];
  sourceRoot = "source/bin";
  propagatedBuildInputs = with pkgs.python3Packages; [
    numpy
    i3ipc
    rockchip-ebc-custom-ioctl
    dbus-next
  ];
  prePatch = ''
    cat > sway_dbus_integration_wrapper.py << EOF
    import asyncio
    import sys
    import sway_dbus_integration

    def main():
      sys.exit(asyncio.run(sway_dbus_integration.main()))
    EOF
  '';
  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup
    setup(
      name='sway_dbus_integration',
      py_modules=['sway_dbus_integration', 'sway_dbus_integration_wrapper'],
      install_requires=[
        'dbus_next',
        'numpy',
        'i3ipc',
        'rockchip_ebc_custom_ioctl',
      ],
      entry_points={
        'console_scripts': [
            'sway_dbus_integration=sway_dbus_integration_wrapper:main',
        ],
      },
      version='2025.05.01',
    )
    EOF
  '';
  meta = with lib; {
    description = "Integration of sway and waybar with rockchip_ebc.";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.gpl3Only;
  };
}
