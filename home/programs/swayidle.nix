{ pkgs, ... }:
let
  loginctl = "${pkgs.systemd}/bin/loginctl";
  display = status: ''${pkgs.sway}/bin/swaymsg "output * power ${status}"'';
  lockAndBlank = "${loginctl} lock-session && ${display "off"}";
in
{
  enable = true;

  events = [
    {
      event = "before-sleep";
      command = "${loginctl} lock-session";
    }
    {
      event = "after-resume";
      command = display "on";
    }
  ];

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
