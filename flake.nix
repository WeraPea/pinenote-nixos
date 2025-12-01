{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
      make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
      evalConfig = import "${nixpkgs}/nixos/lib/eval-config.nix";
      config-native = {
        inherit system;
        modules = [ (import ./configuration.nix) ];
        specialArgs = {
          inherit inputs outputs;
          cross = false;
        };
      };
      config-cross = lib.recursiveUpdate config-native { specialArgs.cross = true; };
      disk-image =
        cfg:
        make-disk-image {
          inherit pkgs lib;
          inherit (evalConfig cfg) config;
          partitionTableType = "legacy";
          fsType = "ext4";
        };
    in
    {
      packages.${system} = import ./packages pkgs;
      nixosModules.default = import ./module.nix inputs;
      nixosConfigurations.pinenote-native = nixpkgs.lib.nixosSystem config-native; # sudo NIX_SSHOPTS="-i /root/.ssh/remotebuildhost" nixos-rebuild test --flake ~/pinenote/pinenote-nixos#pinenote-native --fast --target-host root@pinenote.home
      nixosConfigurations.pinenote-cross = nixpkgs.lib.nixosSystem config-cross;
      disk-image-native = disk-image config-native; # nix build #.disk-image-native --impure after that mount with -o loop,offset=1048576 and rsync the files over to the pinenote to a seperate partition and label the partition as nixos
      disk-image-cross = disk-image config-cross;
    };
}
