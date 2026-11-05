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
      pkgs-x86_64 = import nixpkgs { system = "x86_64-linux"; };
      lib = pkgs.lib;
      make-disk-image = import "${nixpkgs}/nixos/lib/make-disk-image.nix";
      config = {
        inherit system;
        modules = [ (import ./configuration.nix) ];
        specialArgs = {
          inherit inputs outputs;
          cross = false;
          usb = false;
        };
      };
      disk-image =
        config:
        make-disk-image {
          inherit pkgs lib config;
          additionalSpace = "0M";
          label = config.fileSystems."/".label;
        };
    in
    {
      packages.${system} = import ./packages pkgs;
      packages.x86_64-linux = import ./packages pkgs-x86_64;
      nixosModules.default = import ./module.nix inputs;
      nixosConfigurations = {
        pinenote-native = nixpkgs.lib.nixosSystem config;
        pinenote-cross = self.nixosConfigurations.pinenote-native.extendModules {
          specialArgs.cross = true;
        };
        pinenote-usb-native = self.nixosConfigurations.pinenote-native.extendModules {
          specialArgs.usb = true;
        };
        pinenote-usb-cross = self.nixosConfigurations.pinenote-native.extendModules {
          specialArgs.cross = true;
          specialArgs.usb = true;
        };
        pinenote-netboot-native = self.nixosConfigurations.pinenote-native.extendModules {
          modules = [ { pinenote.netboot.enable = true; } ];
        };
        pinenote-netboot-cross = self.nixosConfigurations.pinenote-netboot-native.extendModules {
          modules = [ { pinenote.netboot.squashfsPkgs = pkgs-x86_64; } ];
          specialArgs.cross = true;
        };
      };
      images = lib.mapAttrs' (
        name: value: lib.nameValuePair (name + "-image") (disk-image value.config)
      ) self.nixosConfigurations;
    };
}
