{
  self,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home = {
    stateVersion = "26.05";

    packages = with pkgs; [
      tela-circle-icon-theme
      adwaita-icon-theme
      adw-gtk3

      packet
      spotify
      vesktop
      protonplus
      llama-cpp
    ];

    pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
    };

    file = {
      "firefox-gnome-theme" = {
        target = ".librewolf/default/chrome/firefox-gnome-theme";
        source = fetchGit {
          url = "https://github.com/rafaelmardojai/firefox-gnome-theme.git";
          rev = "26f0620e3877b7ebe1f7388d33da9e015ddfa5ed";
        };
      };
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${self}/nvim";
    };
  };

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        kssh = "kitten ssh";
      };
    };

    kitty = import ./home/kitty.nix;
    librewolf = import ./home/librewolf.nix;
    tmux = import ./home/tmux.nix;
    mangohud = import ./home/mangohud.nix;
    noctalia = import ./home/noctalia.nix;
    neovim = import ./home/nvim.nix { inherit pkgs; };
    btop = import ./home/btop.nix;
  };

  wayland.windowManager.sway = import ./home/sway.nix { inherit pkgs lib; };

  services = {
    mpris-proxy.enable = true;

    swayidle = import ./home/swayidle.nix { inherit pkgs; };
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
    gtk3.extraCss = ''
      window {
        border-radius: 0;
      }
    '';
    gtk4 = {
      extraCss = ''
        window {
          border-radius: 0;
        }
      '';
      theme = config.gtk.theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "application/pdf" = "librewolf.desktop";
        "image/jpeg" = "swayimg.desktop";
        "image/png" = "swayimg.desktop";
        "image/gif" = "swayimg.desktop";
        "image/webp" = "swayimg.desktop";
        "image/bmp" = "swayimg.desktop";
        "image/tiff" = "swayimg.desktop";
        "image/svg+xml" = "swayimg.desktop";
      };
    };
    terminal-exec = {
      enable = true;
      settings = {
        default = [
          "kitty.desktop"
        ];
      };
    };
  };
}
