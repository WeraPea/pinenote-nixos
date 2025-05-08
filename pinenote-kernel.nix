# no real idea what i am doing here
{
  pkgs,
  fetchFromSourcehut,
  ...
}:
(pkgs.buildLinux {
  src = fetchFromSourcehut {
    owner = "~hrdl";
    repo = "linux";
    rev = "b0e82d0f7a25ffa9da40f5d1aa4218023dbfc14d";
    sha256 = "sha256-aenAQqw4ABaXtXM3fnXIg8rBXMqQ5M7eMYmEL1yCB7c=";
  };
  version = "6.15.0-rc3";
  modDirVersion = "6.15.0-rc3";
  defconfig = "pinenote_defconfig";
  ignoreConfigErrors = true;
}).overrideAttrs
  {
    configurePhase = ''
      make ARCH=arm64 pinenote_defconfig
      sed -i 's/CRYPTO_AEGIS128_SIMD=y/CRYPTO_AEGIS128_SIMD=n/' .config
    ''; # by default nix will use pinenote_defconfig but with its own additions, i am to lazy to check what exactly breaks building the kernel so i will just use it unmodified
  }
