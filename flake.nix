{
  description = "p0ryae's opinionated NixOS flake for server, development & gaming across systems";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi";

    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nanocoder.url = "github:nano-collective/nanocoder";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      # builder for standard x86/amd64 machines
      mkHost =
        {
          hostname,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/${hostname}/hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            inputs.lanzaboote.nixosModules.lanzaboote
            ./modules/base.nix
            ./modules/desktop.nix
            ./modules/secure-boot.nix
            { networking.hostName = hostname; }
          ]
          ++ extraModules;
        };

      # builder for Raspberry Pi machines
      mkPiHost =
        {
          hostname,
          piModules ? [ ],
        }:
        inputs.nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}/configtxt.nix
            ./modules/base.nix
            ./modules/pi.nix
            { networking.hostName = hostname; }
          ]
          ++ piModules;
        };
    in
    {
      nixosConfigurations =
        builtins.listToAttrs (
          map
            (hostname: {
              name = hostname;
              value = mkHost {
                inherit hostname;
                extraModules = [ ./hosts/${hostname}/extra.nix ];
              };
            })
            [
              "zenbook"
              "b550f"
            ]
        )
        // {
          rpi5 = mkPiHost {
            hostname = "rpi5";
            piModules = [
              (
                { ... }:
                {
                  imports = with inputs.nixos-raspberrypi.nixosModules; [
                    raspberry-pi-5.base
                    raspberry-pi-5.page-size-16k
                    raspberry-pi-5.display-vc4
                  ];
                }
              )
            ];
          };
        };
    };
}
