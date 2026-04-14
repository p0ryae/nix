{
  pkgs,
  lib,
  inputs,
  self,
  ...
}:
{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
      "steam"
      "steam-unwrapped"
    ];

  networking = {
    wireless.enable = false;

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
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
      "docker"
    ];
    shell = pkgs.fish;
    packages = [ ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs self; };
    users.porya = import ../home.nix;
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
    fastfetch
    nvd
    nodejs
    go
    gcc
    gnumake
    rustup
    elixir
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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  virtualisation.docker.enable = true;
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
  };
}
