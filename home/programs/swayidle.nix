{ pkgs, ... }:
let
  loginctl = "${pkgs.systemd}/bin/loginctl";
  display = status: ''${pkgs.sway}/bin/swaymsg "output * power ${status}"'';
  lockAndBlank = "${loginctl} lock-session && ${display "off"}";
in
{
  enable = true;

  events = {
    before-sleep = "${loginctl} lock-session";
    after-resume = display "on";
    lock = "${pkgs.swaylock}/bin/swaylock -f";
  };

  timeouts = [
    {
      timeout = 600;
      command = lockAndBlank;
      resumeCommand = display "on";
    }
    {
      timeout = 900;
      command = "${pkgs.systemd}/bin/systemctl suspend";
    }
  ];
}
