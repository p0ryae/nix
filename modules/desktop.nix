# NOTE: MADE ONLY FOR AMD GPU DESKTOPS!
{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos;
    kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
  };

  # needed for machine learning, LLMs, and btop
  # well... "needed" is a strong word, so maybe preferred
  nixpkgs.config.rocmSupport = true;

  nixpkgs.overlays = [
    (self: super: {
      yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: {
        postPatch = ''
          substituteInPlace yt_dlp/version.py \
            --replace-fail "UPDATE_HINT = None" 'UPDATE_HINT = "Nixpkgs/NixOS likely already contain an updated version.\n       To get it run nix-channel --update or nix flake update in your config directory."'
          ${lib.optionalString true ''
            # deno is required for full YouTube support (since 2025.11.12).
            # This makes yt-dlp find deno even if it is used as a python dependency, i.e. in kodiPackages.sendtokodi.
            # Crafted so people can replace deno with one of the other JS runtimes.
            substituteInPlace yt_dlp/utils/_jsruntime.py \
              --replace-fail "path = _determine_runtime_path(self._path, '${pkgs.nodejs.meta.mainProgram}')" "path = '${lib.getExe pkgs.nodejs}'"
          ''}
        '';
      });
    })
  ];

  systemd.services = {
    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };

  users.users.porya.extraGroups = lib.mkAfter [
    "i2c"
    "adbusers"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    vazir-fonts
    nerd-fonts.jetbrains-mono
    inter
  ];

  environment.systemPackages = with pkgs; [
    ddcutil
    wiremix
    sway
    autotiling-rs
    colord
    grim
    slurp
    wl-clipboard
    sway-contrib.grimshot
    kitty
    nautilus
    swayimg
    mpv
    lan-mouse
    caligula
    gimp
    easyeffects
    wootility
    android-tools
    imhex
    pdfarranger
    mesa_git
  ];

  environment.sessionVariables.WLR_RENDERER = "vulkan";

  programs = {
    sway.enable = true;
    seahorse.enable = true;
    steam = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
      enable = true;
      platformOptimizations.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    openvpn3.enable = true;
  };

  services = {
    displayManager.ly.enable = true;
    gnome.gnome-keyring.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };
      package = pkgs.pipewire.override { ldacBtDecodeSupport = true; };
    };
    power-profiles-daemon.enable = true;
    upower.enable = true;
    gvfs.enable = true;
    flatpak.enable = true;
    lact.enable = true;
    syncthing = {
      enable = true;
      user = "porya";
      dataDir = "/home/porya";
    };
    scx = {
      enable = true;
      scheduler = "scx_bpfland";
      extraArgs = [
        "-m performance"
        "-w"
      ];
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
