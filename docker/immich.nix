{ self, config, ... }:
{
  age.secrets."immich".file = "${self}/secrets/immich.age";

  systemd.tmpfiles.rules = [
    "d /opt/immich/library  0755 root root -"
    "d /opt/immich/postgres 0755 root root -"
  ];

  systemd.services.create-immich-network = {
    description = "Create immich-net Docker network";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [
      "docker-immich_server.service"
      "docker-immich_machine_learning.service"
      "docker-immich_redis.service"
      "docker-immich_postgres.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      Environment = "PATH=/run/current-system/sw/bin";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect immich-net &>/dev/null \
        || docker network create immich-net
    '';
  };

  virtualisation.oci-containers.containers."immich_server" = {
    image = "ghcr.io/immich-app/immich-server:release";
    ports = [
      "2283:2283/tcp"
    ];
    volumes = [
      "/opt/immich/library:/usr/src/app/upload:rw"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environmentFiles = [ config.age.secrets.immich.path ];
    dependsOn = [
      "immich_redis"
      "immich_postgres"
    ];
    extraOptions = [ "--network=immich-net" ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers."immich_machine_learning" = {
    image = "ghcr.io/immich-app/immich-machine-learning:release";
    volumes = [
      "immich-model-cache:/cache"
    ];
    extraOptions = [
      "--network=immich-net"
      "--health-cmd=redis-cli ping || exit 1"
    ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers."immich_redis" = {
    image = "docker.io/redis:6.2-alpine@sha256:148bb5411c184abd288d9aaed139c98123eeb8824c5d3fce03cf721db58066d8";
    extraOptions = [
      "--network=immich-net"
      "--health-cmd=redis-cli ping || exit 1"
    ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers."immich_postgres" = {
    image = "ghcr.io/immich-app/postgres:14-vectorchord0.3.0-pgvectors0.2.0";
    volumes = [
      "/opt/immich/postgres:/var/lib/postgresql/data:rw"
    ];
    environment = {
      POSTGRES_INITDB_ARGS = "--data-checksums";
    };
    environmentFiles = [ config.age.secrets.immich.path ];
    extraOptions = [ "--network=immich-net" ];
    log-driver = "journald";
  };
}
