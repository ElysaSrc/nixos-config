{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote.url = "github:nix-community/lanzaboote";

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, ...} @ inputs:
    with inputs; {
      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = builtins.listToAttrs (map
        (x: {
          name = x;
          value = nixpkgs.lib.nixosSystem rec {
            specialArgs = {flake-self = self;} // inputs;

            system = "x86_64-linux";

            modules = [
              (./hosts + "/${x}/configuration.nix")
              {
                imports =
                  [
                    (./hosts + "/${x}/hardware.nix")
                  ]
                  ++ builtins.attrValues self.nixosModules;

                environment.systemPackages = [
                  alejandra.defaultPackage.${system}
                ];
              }
              home-manager.nixosModules.home-manager
              lanzaboote.nixosModules.lanzaboote
            ];
          };
        })
        (builtins.attrNames (builtins.readDir ./hosts)));
    };
}
