{
  self,
  lib,
  config,
  ...
}:
let
  podman = "${self}/podman";
in
{
  boot.loader.raspberry-pi.bootloader = "kernel";
  boot.kernel.sysctl = {
    "vm.mmap_rnd_bits" = 28;
    "net.ipv4.ip_forward" = 1;
  };

  imports = [
    "${podman}/adguardhome.nix"
    "${podman}/vaultwarden.nix"
    "${podman}/immich.nix"
    "${podman}/authentik.nix"
    "${podman}/baikal.nix"
  ];

  age.secrets."wifi".file = "${self}/secrets/wifi.age";

  environment.etc."resolv.conf".text = ''
    nameserver 192.168.1.81
  '';

  networking = {
    wireless.enable = false;
    networkmanager.enable = lib.mkForce false;
    resolvconf.enable = false;
    firewall = {
      allowedTCPPorts = [
        80
        443

        # adguardhome
        53
        3000
        8282

        # vaultwarden
        4444

        # immich
        2283

        # baikal
        8484
      ];
      allowedUDPPorts = [
        # adguardhome
        53
        5443
        8989
      ];
      interfaces.wlu1 = {
        allowedUDPPorts = [
          # DHCP server (for WiFi clients)
          67
        ];
      };
    };
    nat = {
      enable = true;
      externalInterface = "end0";
      internalInterfaces = [ "wlu1" ];
    };
    interfaces.wlu1.ipv4.addresses = [
      {
        address = "192.168.10.1";
        prefixLength = 24;
      }
    ];
  };

  services = {
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
      bantime = "24h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };
      jails = {
        nginx-http-auth.settings = {
          filter = "nginx-http-auth";
          action = ''iptables-multiport[name=HTTP, port="http,https"]'';
          logpath = "/var/log/nginx/error.log";
          maxretry = 5;
        };
        nginx-botsearch.settings = {
          filter = "nginx-botsearch";
          action = ''iptables-multiport[name=HTTP, port="http,https"]'';
          logpath = "/var/log/nginx/access.log";
          findtime = 600;
          maxretry = 5;
        };
        sshd.settings = {
          filter = "sshd";
          maxretry = 3;
        };
      };
    };
    nginx = {
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
        "photos.porya.me" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 50000M;
              proxy_read_timeout   600s;
              proxy_send_timeout   600s;
              send_timeout         600s;
            '';
          };
        };
        "authentik.porya.me" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            proxy_buffers 8 16k;
            proxy_buffer_size 32k;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:9000";
            proxyWebsockets = true;
          };
          locations."/outpost.goauthentik.io" = {
            proxyPass = "http://127.0.0.1:9000/outpost.goauthentik.io";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";
            '';
          };
        };
      };
    };
    hostapd = {
      enable = true;
      radios = {
        wlu1 = {
          band = "5g";
          # RTW8822BU driver does not support ACS (automatic channel selection)
          # via survey data collection, so we must pin the channel manually
          channel = 36;
          countryCode = "CA";
          wifi4.capabilities = [
            "HT40+"
            "SHORT-GI-20"
            "SHORT-GI-40"
            "RX-STBC1"
            "LDPC"
          ];
          wifi5.capabilities = [
            "SHORT-GI-80"
            "TX-STBC-2BY1"
            "RX-STBC-1"
            "RXLDPC"
            "SU-BEAMFORMEE"
            "MU-BEAMFORMEE"
            "MAX-MPDU-11454"
          ];
          networks.wlu1 = {
            ssid = "SHAW-2D67-AP";
            authentication = {
              mode = "wpa3-sae-transition";
              saePasswords = [ { passwordFile = config.age.secrets.wifi.path; } ];
              wpaPasswordFile = config.age.secrets.wifi.path;
            };
          };
        };
      };
    };
    dnsmasq = {
      enable = true;
      settings = {
        interface = "wlu1";
        bind-interfaces = true;
        port = 0;
        dhcp-range = [ "192.168.10.50,192.168.10.200,24h" ];
        dhcp-option = [
          "option:router,192.168.10.1"
          "option:dns-server,192.168.1.81"
        ];
      };
    };
  };

  users.users.porya.openssh.authorizedKeys.keys = lib.mkAfter [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQQt3NnHVW0bFJd427d0/7QxTshKX8T74rGzcG9lKRo porya@b550f"
  ];

  systemd.services.hostapd = {
    after = [ "network.target" ];
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults = {
        email = "contact@porya.me";
      };
      certs."vw.porya.me".group = config.services.nginx.group;
      certs."photos.porya.me".group = config.services.nginx.group;
      certs."authentik.porya.me".group = config.services.nginx.group;
    };
    sudo.wheelNeedsPassword = false;
  };
}
