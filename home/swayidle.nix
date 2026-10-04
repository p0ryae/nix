{ pkgs, ... }:
let
  lock = "${pkgs.swaylock}/bin/swaylock --daemonize -c 000000";
  display = status: ''${pkgs.sway}/bin/swaymsg "output * power ${status}"'';
  lockAndBlank = "${lock} && ${display "off"}";
in
{
  enable = true;
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
  events = [
    {
      event = "before-sleep";
      command = lock;
    }
    {
      event = "after-resume";
      command = display "on";
    }
    {
      event = "lock";
      command = lockAndBlank;
    }
  ];
}
