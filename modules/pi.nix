{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  services = {
    openssh.enable = true;
  };

  users.users.porya.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQQt3NnHVW0bFJd427d0/7QxTshKX8T74rGzcG9lKRo porya@b550f"
  ];
}
