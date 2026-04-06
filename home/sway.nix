{ pkgs, lib }:
{
  enable = true;
  wrapperFeatures.gtk = true;
  checkConfig = false;
  config =
    let
      modifier = "Mod4";
      ipc = "noctalia-shell ipc call";
    in
    {
      modifier = modifier;
      terminal = "kitty";
      menu = "${ipc} launcher toggle";
      bars = [ ];
      input = {
        "type:touchpad" = {
          dwt = "disabled";
          tap = "enabled";
          natural_scroll = "enabled";
          drag_lock = "disabled";
        };
      };
      output = {
        "*" = {
          adaptive_sync = "on";
          color_profile = "icc ${pkgs.colord}/share/color/icc/colord/AppleRGB.icc";
        };
      };
      startup = [
        { command = "autotiling-rs"; }
        { command = "noctalia-shell"; }
      ];
      gaps = {
        inner = 5;
        outer = 10;
      };
      window = {
        border = 2;
        titlebar = false;
        commands = [ ];
      };
      keybindings = lib.mkOptionDefault {
        "${modifier}+space" = "exec ${ipc} launcher toggle";
        "${modifier}+s" = "exec ${ipc} controlCenter toggle";
        "${modifier}+comma" = "exec ${ipc} settings toggle";
        "--locked XF86AudioRaiseVolume" = "exec ${ipc} volume increase";
        "--locked XF86AudioLowerVolume" = "exec ${ipc} volume decrease";
        "--locked XF86AudioMute" = "exec ${ipc} volume muteOutput";
        "--locked XF86MonBrightnessUp" = "exec ${ipc} brightness increase";
        "--locked XF86MonBrightnessDown" = "exec ${ipc} brightness decrease";

        "${modifier}+Shift+s" = "exec selection=$(slurp) && grim -g \"$selection\" - | wl-copy";

        "Print" =
          "exec grimshot save output - | tee ~/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy";
      };
      colors = {
        focused = {
          border = "#f38ba8";
          background = "#89b4fa";
          text = "#ffffff";
          indicator = "#f38ba8";
          childBorder = "#f38ba8";
        };
        focusedInactive = {
          border = "#585b70";
          background = "#585b70";
          text = "#cdd6f4";
          indicator = "#585b70";
          childBorder = "#585b70";
        };
        unfocused = {
          border = "#313244";
          background = "#313244";
          text = "#a6adc8";
          indicator = "#313244";
          childBorder = "#313244";
        };
      };
    };
}
