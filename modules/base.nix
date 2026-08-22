{
  pkgs,
  inputs,
  ...
}:
{
  boot = {
    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
      "vm.swappiness" = "20";
      "vm.vfs_cache_pressure" = "50";
    };
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
  };

  networking = {
    wireless.enable = false;

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      plugins = with pkgs; [ networkmanager-openconnect ];
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
    memoryPercent = 50;
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
    p7zip
    lshw
    lsof
    ethtool
    nettools
    tcpdump
    usbutils
    ripgrep
    fd
    iw
    tmux
    fastfetch
    nvd
    nixos-anywhere
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    jq
    nodejs
    go
    gcc
    gnumake
    rustup
    beamPackages.elixir
    python3
    yarn-berry
    eza
    bat
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
    fstrim.enable = true;
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

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "@wheel" ];
    };
  };
}
