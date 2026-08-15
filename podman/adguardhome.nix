{
  virtualisation.oci-containers.containers.adguardhome = {
    image = "docker.io/adguard/adguardhome:latest";
    # ports = [
    #   "53:53/tcp" # plain DNS over TCP
    #   "53:53/udp" # plain DNS over UDP
    #   "8282:80/tcp" # HTTP web interface
    #   # "8989:443/tcp"
    #   # "8989:443/udp"
    #   # "853:853/tcp" # DNS-over-TLS
    #   # "5443:5443/tcp" # DNSCrypt
    #   # "5443:5443/udp" # DNSCrypt
    #   "3000:3000/tcp" # initial setup web interface
    # ];
    volumes = [
      "/opt/adguardhome/conf:/opt/adguardhome/conf:rw"
      "/opt/adguardhome/work:/opt/adguardhome/work:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=host"
      "--label=io.containers.autoupdate=registry"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /opt/adguardhome/conf 0755 root root -"
    "d /opt/adguardhome/work 0755 root root -"
  ];
}
