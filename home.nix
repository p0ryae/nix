{ nvim-config }:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    atool
    httpie

    tela-circle-icon-theme
    adwaita-icon-theme
    adw-gtk3

    packet
  ];

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  programs.fish.enable = true;

  programs.kitty = import ./home/kitty.nix;

  programs.librewolf = {
    enable = true;
    settings = {
      "identity.fxaccounts.enabled" = true;
      "privacy.resistFingerprinting" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;
    };
  };

  wayland.windowManager.sway = import ./home/sway.nix { inherit pkgs lib; };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Tela-circle-dark";
      package = pkgs.tela-circle-icon-theme;
    };
    gtk4.theme = config.gtk.theme;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  xdg.configFile.nvim.source = nvim-config;

  home.stateVersion = "25.11";
}
