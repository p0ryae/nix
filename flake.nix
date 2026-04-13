{
  description = "p0ryae's nixos flake";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      commonModule =
        {
          pkgs,
          lib,
          ...
        }:
        {
          imports = [
            inputs.nix-gaming.nixosModules.platformOptimizations
            inputs.nix-gaming.nixosModules.pipewireLowLatency
          ];

          nixpkgs = {
            config = {
              allowUnfreePredicate =
                pkg:
                builtins.elem (lib.getName pkg) [
                  "spotify"
                  "steam"
                  "steam-unwrapped"
                ];
              rocmSupport = true;
            };
          };

          networking.networkmanager.enable = true;
          systemd = {
            oomd = {
              enable = true;
              enableRootSlice = true;
              enableUserSlices = true;
            };
            services = {
              NetworkManager-wait-online.enable = false;
              flatpak-repo = {
                wantedBy = [ "multi-user.target" ];
                path = [ pkgs.flatpak ];
                script = ''
                  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                '';
              };
            };
          };

          zramSwap = {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 25;
          };

          time.timeZone = "America/Vancouver";

          i18n.defaultLocale = "en_CA.UTF-8";

          users.users.porya = {
            isNormalUser = true;
            description = "porya";
            extraGroups = [
              "networkmanager"
              "wheel"
              "docker"
            ];
            shell = pkgs.fish;
            packages = [ ];
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = {
              inherit inputs self;
            };

            users = {
              porya = import ./home.nix;
            };
          };

          environment.systemPackages = with pkgs; [
            git
            wget
            openssl
            unzip
            lshw
            lsof
            ripgrep
            fd
            tmux
            btop
            sbctl
            wiremix
            fastfetch
            nvd

            sway
            autotiling-rs
            colord
            grim
            slurp
            wl-clipboard
            sway-contrib.grimshot

            kitty
            nautilus
            docker

            nodejs
            go
            gcc
            gnumake
            rustup
            elixir
          ];

          environment.sessionVariables = {
            WLR_RENDERER = "vulkan";
          };

          fonts.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
            inter
          ];

          programs = {
            neovim = {
              enable = true;
              defaultEditor = true;
              viAlias = true;
              vimAlias = true;
            };
            fish.enable = true;
            sway.enable = true;
            steam = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
              enable = true;
              platformOptimizations.enable = true;
            };
            gamemode.enable = true;
            appimage = {
              enable = true;
              binfmt = true;
            };
          };

          services = {
            xserver.xkb = {
              layout = "us";
              variant = "";
            };
            displayManager.ly.enable = true;
            pipewire = {
              enable = true;
              alsa.enable = true;
              pulse.enable = true;
              lowLatency = {
                enable = true;
                quantum = 64;
                rate = 48000;
              };
            };
            power-profiles-daemon.enable = true;
            udisks2.enable = true;
            gvfs.enable = true;
            flatpak.enable = true;
            lact.enable = true;
          };

          xdg = {
            portal = {
              enable = true;
              wlr.enable = true;
            };
          };

          virtualisation.docker.enable = true;
          # make pipewire realtime-capable
          security.rtkit.enable = true;
          system.stateVersion = "25.11";

          nix = {
            settings = {
              auto-optimise-store = true;
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              extra-substituters = [
                "https://noctalia.cachix.org"
                "https://nixos-raspberrypi.cachix.org"
              ];
              extra-trusted-public-keys = [
                "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
                "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
              ];
            };
          };
        };

      secureBootModule =
        { lib, ... }:
        {
          boot = {
            kernelPackages = lib.mkDefault (import nixpkgs { system = "x86_64-linux"; }).linuxPackages_zen;
            kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
            loader.systemd-boot.enable = lib.mkForce false;
            loader.efi.canTouchEfiVariables = true;
            bootspec.enable = true;
            lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
            initrd.systemd.enable = true;
          };
        };

      mkHost =
        {
          hostname,
          system ? "x86_64-linux",
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${hostname}/hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            inputs.lanzaboote.nixosModules.lanzaboote
            commonModule
            secureBootModule
            { networking.hostName = hostname; }
          ]
          ++ extraModules;
        };

      mkPiHost =
        {
          hostname,
          piModules ? [ ],
        }:
        inputs.nixos-raspberrypi.lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          modules = [
            ./hosts/${hostname}/hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            commonModule
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
                    raspberry-pi-5.bluetooth
                  ];
                }
              )
            ];
          };
        };
    };
}
