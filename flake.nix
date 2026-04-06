{
  description = "p0ryae's nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }:
    let
      commonModule = { config, pkgs, lib, ... }: {
        networking.networkmanager.enable = true;
        systemd.services.NetworkManager-wait-online.enable = false;
        
        hardware.bluetooth.enable = true;
        
        time.timeZone = "America/Vancouver";
        
        i18n.defaultLocale = "en_CA.UTF-8";
        
        services.xserver.xkb = { layout = "us"; variant = ""; };

        users.users.porya = {
          isNormalUser = true;
          description = "porya";
          extraGroups = [ "networkmanager" "wheel" "docker" ];
          shell = pkgs.fish;
          packages = [ ];
        };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.porya = import ./home.nix;

        environment.systemPackages = with pkgs; [
          git wget openssl unzip lshw ripgrep fd tmux btop sbctl lon wiremix
          fastfetch tree-sitter sway autotiling-rs noctalia-shell colord grim
          slurp sway-contrib.grimshot librewolf kitty opencode docker nixd
          nodejs go gopls gcc gnumake rustup elixir
        ];
        environment.sessionVariables.WLR_RENDERER = "vulkan";
        fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono inter ];

        programs = {
          neovim = { enable = true; defaultEditor = true; viAlias = true; vimAlias = true; };
          fish.enable = true;
          sway.enable = true;
        };

        services = {
          displayManager.ly.enable = true;
          pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };
        };

        xdg.portal = { enable = true; wlr.enable = true; };
        virtualisation.docker.enable = true;
        security.rtkit.enable = true;
        system.stateVersion = "25.11";

        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          extra-substituters = [ "https://noctalia.cachix.org" ];
          extra-trusted-public-keys = [
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };
      };

      secureBootModule = { lib, ... }: {
        boot = {
          kernelPackages = lib.mkDefault (import nixpkgs { system = "x86_64-linux"; }).linuxPackages_latest;
          loader.systemd-boot.enable = lib.mkForce false;
          loader.efi.canTouchEfiVariables = true;
          bootspec.enable = true;
          lanzaboote = { enable = true; pkiBundle = "/var/lib/sbctl"; };
          initrd.systemd.enable = true;
        };
      };

      mkHost = { hostname, system ? "x86_64-linux", extraModules ? [] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${hostname}/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            lanzaboote.nixosModules.lanzaboote
            commonModule
            secureBootModule
            { networking.hostName = hostname; }
          ] ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        zenbook = mkHost { 
          hostname = "zenbook";
          extraModules = [ ./hosts/zenbook/extra.nix ];
        };
        b550f = mkHost {
          hostname = "b550f";
        };
      };
    };
}
