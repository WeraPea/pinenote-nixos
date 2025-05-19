{
  lib,
  pkgs,
  fetchFromSourcehut,
  waveform-read-file,
  ...
}:

pkgs.python3Packages.buildPythonPackage {
  pname = "wbf-to-custom";
  version = "unstable-2025-04-29";
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "pinenote-dist";
    rev = "81a8ea7faa40b3731e4aa83034250862f4e698d6";
    hash = "sha256-6yhPQ25Grgyazx1Dob/jwD06dVg2JUdh/tFjsk8mtt4=";
  };
  sourceRoot = "source/bin";
  propagatedBuildInputs = with pkgs.python3Packages; [
    numpy
    pandas
    waveform-read-file
  ];
  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup
    setup(
      name='wbf_to_custom',
      py_modules=['wbf_to_custom'],
      install_requires=[
        'pandas'
        'numpy',
        'read_file',
      ],
      entry_points={
        'console_scripts': [
            'wbf_to_custom=wbf_to_custom:main',
        ],
      },
      version='2025.04.29',
    )
    EOF
  '';
  meta = with lib; {
    description = "Conversion script of wbf to custom format.";
    homepage = "https://git.sr.ht/~hrdl/pinenote-dist";
    platforms = platforms.all;
    license = licenses.gpl3Only;
  };
}
