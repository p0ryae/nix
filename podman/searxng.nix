{ pkgs, ... }:
{
  systemd.services.podman-network-searxng = {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.podman}/bin/podman network exists searxng || \
      ${pkgs.podman}/bin/podman network create searxng
    '';
  };

  virtualisation.oci-containers.containers.searxng-valkey = {
    image = "docker.io/valkey/valkey:9-alpine";
    cmd = [
      "valkey-server"
      "--save"
      "30"
      "1"
      "--loglevel"
      "warning"
    ];
    volumes = [
      "/opt/searxng/valkey-data:/data/:rw"
    ];
    extraOptions = [
      "--network=searxng"
      "--network-alias=valkey"
    ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers.searxng-core = {
    image = "docker.io/searxng/searxng:latest";
    ports = [
      "8080:8080/tcp"
    ];
    environmentFiles = [
      "/opt/searxng/.env"
    ];
    volumes = [
      "/opt/searxng/core-config:/etc/searxng/:Z"
      "/opt/searxng/core-data:/var/cache/searxng/:rw"
    ];
    extraOptions = [
      "--network=searxng"
      "--network-alias=core"
    ];
    dependsOn = [ "searxng-valkey" ];
    log-driver = "journald";
  };

  systemd.tmpfiles.rules = [
    "d /opt/searxng/core-config   0755 root root -"
    "d /opt/searxng/core-data     0755 root root -"
    "d /opt/searxng/valkey-data   0755 root root -"
  ];
}
