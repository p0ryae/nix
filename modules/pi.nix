{
  self,
  lib,
  config,
  ...
}:
{
  boot.loader.raspberry-pi.bootloader = "kernel";

  imports = [
    "${self}/docker/adguardhome.nix"
    "${self}/docker/vaultwarden.nix"
  ];

  networking.networkmanager.ensureProfiles.profiles."home-wifi".ipv4.dns = lib.mkForce "127.0.0.1";

  systemd.tmpfiles.rules = [
    "d /opt/adguardhome/conf 0755 root root -"
    "d /opt/adguardhome/work 0755 root root -"
    "d /opt/vaultwarden/data 0755 root root -"
  ];

  networking.firewall = {
    allowedTCPPorts = [
      80
      443

      # adguardhome
      53
      853
      3000
      5443
      8282
      8989

      # vaultwarden
      4444
    ];
    allowedUDPPorts = [
      # adguardhome
      53
      5443
      8989
    ];
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "vw.porya.me" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:4444";
          proxyWebsockets = true;
        };
      };
    };
  };

  users.users.porya.openssh.authorizedKeys.keys = lib.mkAfter [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQQt3NnHVW0bFJd427d0/7QxTshKX8T74rGzcG9lKRo porya@b550f"
  ];

  security = {
    acme = {
      acceptTerms = true;
      email = "contact@porya.me";
      certs."vw.porya.me".group = config.services.nginx.group;
    };
    sudo.wheelNeedsPassword = false;
  };
}
