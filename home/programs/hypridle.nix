{ pkgs, ... }:
let
  loginctl = "${pkgs.systemd}/bin/loginctl";
  display = status: ''${pkgs.sway}/bin/swaymsg "output * power ${status}"'';
  lockAndBlank = "${loginctl} lock-session && ${display "off"}";
in
{
  enable = true;
  settings = {
    general = {
      before_sleep_cmd = "${loginctl} lock-session";
      after_sleep_cmd = display "on";
    };

    listener = [
      {
        timeout = 600;
        on-timeout = lockAndBlank;
        on-resume = display "on";
      }
      {
        timeout = 900;
        on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
