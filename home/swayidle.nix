{ pkgs, ... }:
let
  lock = "${pkgs.swaylock}/bin/swaylock --daemonize -c 000000";
  display = status: ''${pkgs.sway}/bin/swaymsg "output * power ${status}"'';
  displayOff = display "off";
  displayOn = display "on";
in
{
  enable = true;
  timeouts = [
    {
      timeout = 300;
      command = lock;
    }
    {
      timeout = 600;
      command = displayOff;
      resumeCommand = displayOn;
    }
  ];
  events = {
    before-sleep = "${displayOff}; ${lock}";
    after-resume = displayOn;
  };
}
