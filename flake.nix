{
  description = "p0ryae's nixos flake";

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";

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

          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "spotify"
              "steam"
              "steam-unwrapped"
            ];

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

          hardware.bluetooth.enable = true;

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
            ripgrep
            fd
            tmux
            btop
            sbctl
            wiremix
            fastfetch
            tree-sitter

            sway
            autotiling-rs
            colord
            grim
            slurp
            wl-clipboard
            sway-contrib.grimshot

            kitty
            nautilus
            opencode
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
            steam = {
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
              extra-substituters = [ "https://noctalia.cachix.org" ];
              extra-trusted-public-keys = [
                "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
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
    in
    {
      nixosConfigurations = builtins.listToAttrs (
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
      );
    };
}
