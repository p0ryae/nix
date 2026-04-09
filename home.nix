{
  config,
  pkgs,
  lib,
  noctalia,
  ...
}:
{
  imports = [
    noctalia.homeModules.default
  ];

  home = {
    stateVersion = "25.11";

    packages = with pkgs; [
      atool
      httpie

      tela-circle-icon-theme
      adwaita-icon-theme
      adw-gtk3

      packet
      spotify
      vesktop
      protonplus
      llama-cpp-vulkan
    ];

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
    };

    file."firefox-gnome-theme" = {
      target = ".librewolf/default/chrome/firefox-gnome-theme";
      source = fetchGit {
        url = "https://github.com/rafaelmardojai/firefox-gnome-theme.git";
        rev = "26f0620e3877b7ebe1f7388d33da9e015ddfa5ed";
      };
    };
  };

  programs = {
    fish.enable = true;

    kitty = import ./home/kitty.nix;
    librewolf = import ./home/librewolf.nix;
    tmux = import ./home/tmux.nix;
    mangohud = import ./home/mangohud.nix;
    noctalia-shell = import ./home/noctalia.nix;
  };

  wayland.windowManager.sway = import ./home/sway.nix { inherit pkgs lib; };

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
      };
    };
  };

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

    font = {
      name = "Inter Medium";
      size = 11;
    };

    gtk4.theme = config.gtk.theme;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "nautilus.desktop";
      };
    };

    # configFile.nvim.source = nvim-config;
  };
}
