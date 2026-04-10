{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ddcutil
  ];
  networking = {
    nameservers = [
      "192.168.1.81"
    ];
    useDHCP = false;
    dhcpcd.enable = false;
    networkmanager.dns = "none";
  };
}
