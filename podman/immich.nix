{ self, config, ... }:
{
  age.secrets."immich".file = "${self}/secrets/immich.age";

  virtualisation.oci-containers.containers.immich-server = {
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
      "immich-redis"
      "immich-postgres"
    ];
    log-driver = "journald";
  };
  virtualisation.oci-containers.containers.immich-machine-learning = {
    image = "ghcr.io/immich-app/immich-machine-learning:release";
    volumes = [
      "immich-model-cache:/cache"
    ];
    log-driver = "journald";
  };
  virtualisation.oci-containers.containers.immich-redis = {
    image = "docker.io/valkey/valkey:9@sha256:3b55fbaa0cd93cf0d9d961f405e4dfcc70efe325e2d84da207a0a8e6d8fde4f9";
    extraOptions = [
      "--health-cmd=redis-cli ping || exit 1"
    ];
    log-driver = "journald";
  };
  virtualisation.oci-containers.containers.immich-postgres = {
    image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
    volumes = [
      "/opt/immich/postgres:/var/lib/postgresql/data:rw"
    ];
    environment = {
      POSTGRES_INITDB_ARGS = "--data-checksums";
    };
    environmentFiles = [ config.age.secrets.immich.path ];
    log-driver = "journald";
  };

  systemd.tmpfiles.rules = [
    "d /opt/immich/library  0755 root root -"
    "d /opt/immich/postgres 0755 root root -"
  ];
}
