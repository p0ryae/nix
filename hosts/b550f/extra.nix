{ ... }:
{
  networking = {
    nameservers = [
      "192.168.1.81"
      # "1.1.1.1"
    ];
    networkmanager.dns = "none";
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
}
