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
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
}
