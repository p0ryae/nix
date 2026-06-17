{
  enable = true;

  settings = {
    shell = {
      font_family = "JetBrainsMono Nerd Font";
      font = "JetBrainsMono Nerd Font";
      settings_show_advanced = true;
      corner_radius_scale = 1.5;
    };

    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Rosé Pine";
    };

    bar.widgets = {
      background_opacity = 0.9;
      capsule = true;
      padding = 8;
      radius = 0;
      end = [
        "tray"
        "notifications"
        "battery"
        "volume"
        "brightness"
        "control-center"
        "clock"
        "session"
      ];
      center = [ "workspaces" ];
      font_family = "JetBrainsMono Nerd Font";
      margin_edge = 0;
      margin_ends = 0;
      start = [
        "launcher"
        "group:g1"
        "active_window"
        "media"
      ];

      capsule_group = [
        {
          fill = "surface_variant";
          id = "g1";
          members = [
            "ram"
            "cpu"
            "temp"
          ];
          opacity = 1.0;
          padding = 6.0;
        }
      ];
    };

    lockscreen_widgets = {
      enabled = false;
      schema_version = 2;
      widget_order = [ "lockscreen-login-box@eDP-1" ];

      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };

      widget."lockscreen-login-box@eDP-1" = {
        box_height = 0.0;
        box_width = 0.0;
        cx = 873.0;
        cy = 967.0;
        output = "eDP-1";
        rotation = 0.0;
        type = "login_box";

        settings = {
          background_color = "surface_variant";
          background_opacity = 0.88;
          background_radius = 12.0;
          input_opacity = 1.0;
          input_radius = 6.0;
          show_login_button = true;
        };
      };
    };

    wallpaper = {
      directory = "/home/porya/nix/assets";

      default.path = "/home/porya/nix/assets/FW 13 Wallpaper 5.jpg";
      last.path = "/home/porya/nix/assets/FW 13 Wallpaper 5.jpg";
      monitors.eDP-1.path = "/home/porya/nix/assets/FW 13 Wallpaper 5.jpg";
    };

    widget = {
      clock.format = "%a %b %-d %I:%M %p";
      control-center.glyph = "adjustments-alt";
      cpu.show_label = false;
      ram.show_label = false;
      media.hide_when_no_media = true;
      sysmon = {
        show_label = false;
        stat = "ram_used";
      };
      temp.show_label = false;
      tray.drawer = true;
      workspaces.display = "none";
    };

    osd.kinds = {
      media = false;
    };
  };
}
