{ lib, pkgs, ... }:
{
  boot.loader.raspberry-pi.bootloader = "kernel";

  services = {
    openssh.enable = true;
  };

  users.users.porya.openssh.authorizedKeys.keys = lib.mkAfter [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQQt3NnHVW0bFJd427d0/7QxTshKX8T74rGzcG9lKRo porya@b550f"
  ];
}
