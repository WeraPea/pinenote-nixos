{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      cfg = import ./configuration.nix;
      make-disk-image = import <nixpkgs/nixos/lib/make-disk-image.nix>;
      evalConfig = import <nixpkgs/nixos/lib/eval-config.nix>;
      pkgsCross = import nixpkgs {
        # for cross compiling the kernel instead of running the whole compilation through qemu/binfmt
        crossSystem = {
          config = "aarch64-unknown-linux-gnu";
        };
      };
      config = {
        inherit system;
        modules = [ cfg ];
        specialArgs = {
          inherit pkgsCross;
        };
      };
    in
    {
      nixosConfiguration.pinenote = nixpkgs.lib.nixosSystem config;
      diskImage = make-disk-image {
        inherit pkgs lib;
        inherit (evalConfig config) config;
        partitionTableType = "legacy";
        fsType = "ext4";
      }; # nix build #.diskImage --impure (this is most likely not the way to get the system files) after that mount with -o loop,offset=1048576 and rsync the files over to the pinenote on a seperate and label the partition as nixos
    };
}
