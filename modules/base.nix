{
  self,
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "steam"
      "steam-unwrapped"
      "wootility"
    ];

  age.secrets.network-manager = {
    file = "${self}/secrets/network-manager.age";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking = {
    wireless.enable = false;

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      ensureProfiles = {
        environmentFiles = [ config.age.secrets.network-manager.path ];
        profiles."home-wifi" = {
          connection = {
            id = "SHAW-2D67";
            type = "wifi";
          };
          wifi = {
            ssid = "SHAW-2D67";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "@psk@";
          };
          ipv4 = {
            method = "auto";
            dns = "192.168.1.81";
            ignore-auto-dns = "true";
          };
          ipv6.method = "auto";
        };
      };
    };
  };

  systemd = {
    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
    };

    # The notion of "online" is a broken concept
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    # https://github.com/NixOS/nixpkgs/issues/247608
    services.NetworkManager-wait-online.enable = false;
    network.wait-online.enable = false;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";

  users.users.porya = {
    initialPassword = "p0ryae";
    isNormalUser = true;
    description = "porya";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
    shell = pkgs.fish;
    packages = [ ];
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    openssl
    unzip
    lshw
    lsof
    usbutils
    ripgrep
    fd
    tmux
    fastfetch
    nvd
    nixos-anywhere
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default

    nodejs
    go
    gcc
    gnumake
    rustup
    elixir
    python3
  ];

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
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.backend = "podman";
  };
  security.rtkit.enable = true;
  system.stateVersion = "25.11";

  nix.settings = {
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
    trusted-users = [ "@wheel" ];
  };
}
