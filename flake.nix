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
      base-url = "https://github.com/WeraPea/pinenote-nixos/blob/main";
      mkPackages =
        pkgs:
        let
          packages = import ./packages pkgs;
        in
        packages
        // {
          options-docs =
            (pkgs.nixosOptionsDoc {
              options = (self.nixosConfigurations.pinenote-native).options.pinenote;
              transformOptions =
                opt:
                opt
                // {
                  declarations = map (d: rec {
                    name = lib.removePrefix "${self}/" (toString d);
                    url = "${base-url}/${name}";
                  }) opt.declarations;
                };
            }).optionsCommonMark;
          packages-docs = pkgs.writeText "packages.md" (
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                name: p:
                let
                  description = p.meta.description or "";
                  homepage =
                    if p.meta ? homepage then
                      lib.concatStringsSep "" (map (h: "\n- [Homepage](${h})") (lib.toList p.meta.homepage))
                    else
                      "";
                  declaration = lib.removePrefix "${self}/" (toString p.meta.position);
                  parts = lib.splitString ":" declaration;
                  file = lib.elemAt parts 0;
                  line = lib.elemAt parts 1;
                  url = "${base-url}/${file}#L${line}";
                in
                ''
                  ## ${name}
                  ${description}
                  - Version: `${p.version}`${homepage}
                  - Source: [${declaration}](${url})
                  - Licence: `${p.meta.license.shortName or ""}`
                ''
              ) packages
            )
          );
          update-docs = pkgs.writeShellScriptBin "update-docs" ''
            cat $(nix build .#options-docs --no-link --print-out-paths) > ./docs/options.md
            cat $(nix build .#packages-docs --no-link --print-out-paths) > ./docs/packages.md
          '';
        };
    in
    {
      packages.${system} = mkPackages pkgs;
      packages.x86_64-linux = mkPackages pkgs-x86_64;
      nixosModules.default = import ./modules inputs;
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
