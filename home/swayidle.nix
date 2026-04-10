{ pkgs, ... }:
{
  enable = true;
  timeouts = [
    {
      timeout = 300;
      command = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
    }
    {
      timeout = 600;
      command = ''${pkgs.sway}/bin/swaymsg "output * power off"'';
      resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * power on"'';
    }
  ];
  events = {
    before-sleep = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
  };
}
