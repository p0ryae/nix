{
  description = "p0ryae's opinionated NixOS flake for server, development & gaming across systems";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/nixos-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    noctalia.url = "github:noctalia-dev/noctalia";
    affinity-nix.url = "github:mrshmllow/affinity-nix";
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      chaotic,
      ...
    }:
    let
      mkHomeManager =
        { homeConfig }:
        {
          imports = [ inputs.home-manager.nixosModules.home-manager ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs self; };
            users.porya = import homeConfig;
          };
        };

      # builder for standard x86/amd64 machines
      mkHost =
        {
          hostname,
          homeConfig ? ./home.nix,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [
            chaotic.nixosModules.default
            inputs.agenix.nixosModules.default
            ./hosts/${hostname}/hardware-configuration.nix
            inputs.lanzaboote.nixosModules.lanzaboote
            ./modules/base.nix
            ./modules/desktop.nix
            ./modules/secure-boot.nix
            ./modules/azure-vpn-client/azure-vpn-client.nix
            (mkHomeManager { inherit homeConfig; })
            { networking.hostName = hostname; }
          ]
          ++ extraModules;
        };

      # builder for Raspberry Pi machines
      mkPiHost =
        {
          hostname,
          homeConfig ? ./home-hl.nix,
          piModules ? [ ],
        }:
        inputs.nixos-raspberrypi.lib.nixosSystem {
          nixpkgs = inputs.nixpkgs;
          specialArgs = { inherit inputs self; };
          modules = [
            inputs.agenix.nixosModules.default
            inputs.disko.nixosModules.disko
            ./hosts/${hostname}/disk.nix
            ./hosts/${hostname}/configtxt.nix
            ./modules/base.nix
            ./modules/pi.nix
            (mkHomeManager { inherit homeConfig; })
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
                    # raspberry-pi-5.page-size-16k
                    raspberry-pi-5.display-vc4
                  ];
                }
              )
            ];
          };
        };
    };
}
