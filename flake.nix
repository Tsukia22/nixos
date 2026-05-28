{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        tsu01 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/tsu01/configuration.nix ];
        };
        xan01 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/xan01/configuration.nix ];
        };
        xan02 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/xan02/configuration.nix ];
        };
      };
    };
}