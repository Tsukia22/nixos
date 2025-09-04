{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations = {
        tsukiapc = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/desktop/tsukiapc/configuration.nix ];
        };

        xanedithaspc = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/desktop/xanedithaspc/configuration.nix ];
        };

        tsu01 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/server/tsu01/configuration.nix ];
        };

        xan01 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/server/xan01/configuration.nix ];
        };
        
        tsuacer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/laptop/tsuacer/configuration.nix ];
        };
      };
    };
}