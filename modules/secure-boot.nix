{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = true;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys = true;
      autoEnrollKeys = true;
    };
    initrd.systemd.enable = true;
  };
}
