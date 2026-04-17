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
    kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
  };

  # needed for machine learning, LLMs, and btop
  # well... "needed" is a strong word, so maybe preferred
  nixpkgs.config.rocmSupport = true;

  systemd.services = {
    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };

  users.users.porya.extraGroups = lib.mkAfter [ "i2c" ];

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
    loupe
    clapper
    lan-mouse
    caligula
  ];

  environment.sessionVariables.WLR_RENDERER = "vulkan";

  programs = {
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
    upower.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    flatpak.enable = true;
    lact.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
