{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }@inputs:
    let
      inherit (self) outputs;
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      make-disk-image = import <nixpkgs/nixos/lib/make-disk-image.nix>;
      evalConfig = import <nixpkgs/nixos/lib/eval-config.nix>;
      cfg = import ./configuration.nix;
      pkgsCross = import nixpkgs {
        # for cross compiling the kernel instead of running the whole compilation through qemu/binfmt
        system = "x86_64-linux";
        crossSystem = {
          config = "aarch64-unknown-linux-gnu";
        };
      };
      config = {
        inherit system;
        modules = [ cfg ];
        specialArgs = {
          inherit inputs outputs;
        };
      };
    in
    {
      packages.${system} = import ./packages { inherit pkgs pkgsCross; }; # "https://pinenote-packages.cachix.org" for kernel
      nixosModules.default = import ./module.nix inputs;
      nixosConfigurations.pinenote = nixpkgs.lib.nixosSystem config; # sudo NIX_SSHOPTS="-i /root/.ssh/remotebuildhost" nixos-rebuild test --flake ~/pinenote/pinenote-nixos#pinenote --fast --target-host root@pinenote.home
      diskImage = make-disk-image {
        inherit pkgs lib;
        inherit (evalConfig config) config;
        partitionTableType = "legacy";
        fsType = "ext4";
      }; # nix build #.diskImage --impure (this is most likely not the way to get the system files) after that mount with -o loop,offset=1048576 and rsync the files over to the pinenote to a seperate partition and label it as nixos
    };
}
