{ ... }:
{
  virtualisation.oci-containers.containers.baikal = {
    image = "docker.io/ckulka/baikal:latest";
    ports = [
      "8484:80/tcp"
    ];
    volumes = [
      "/opt/baikal/config:/var/www/baikal/config:rw"
      "/opt/baikal/data:/var/www/baikal/Specific:rw"
    ];
    extraOptions = [ "--label=io.containers.autoupdate=registry" ];
    log-driver = "journald";
  };

  systemd.tmpfiles.rules = [
    "d /opt/baikal/config    0755 root root -"
    "d /opt/baikal/data      0755 root root -"
  ];
}
