{ self, config, ... }:
{
  age.secrets."authentik".file = "${self}/secrets/authentik.age";

  virtualisation.oci-containers.containers.authentik-postgres = {
    image = "docker.io/library/postgres:16-alpine";
    volumes = [
      "authentik-database:/var/lib/postgresql/data"
    ];
    environment = {
      POSTGRES_USER = "authentik";
      POSTGRES_DB = "authentik";
    };
    environmentFiles = [ config.age.secrets.authentik.path ];
    extraOptions = [
      "--health-cmd=pg_isready -d authentik -U authentik"
      "--health-start-period=20s"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-timeout=5s"
    ];
    log-driver = "journald";
  };
  virtualisation.oci-containers.containers.authentik-redis = {
    image = "docker.io/library/redis:alpine";
    cmd = [
      "--save"
      "60"
      "1"
      "--loglevel"
      "warning"
    ];
    volumes = [
      "authentik-redis:/data"
    ];
    extraOptions = [
      "--health-cmd=redis-cli ping | grep PONG"
      "--health-start-period=20s"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-timeout=3s"
    ];
    log-driver = "journald";
  };
  virtualisation.oci-containers.containers.authentik-server = {
    image = "ghcr.io/goauthentik/server:2025.6.4";
    cmd = [ "server" ];
    ports = [
      "9000:9000/tcp"
      "9443:9443/tcp"
    ];
    volumes = [
      "/opt/authentik/media:/media"
      "/opt/authentik/custom-templates:/templates"
    ];
    environment = {
      AUTHENTIK_REDIS__HOST = "authentik-redis";
      AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
      AUTHENTIK_POSTGRESQL__USER = "authentik";
      AUTHENTIK_POSTGRESQL__NAME = "authentik";
    };
    environmentFiles = [ config.age.secrets.authentik.path ];
    dependsOn = [
      "authentik-postgres"
      "authentik-redis"
    ];
    log-driver = "journald";
  };
  virtualisation.oci-containers.containers.authentik-worker = {
    image = "ghcr.io/goauthentik/server:2025.6.4";
    cmd = [ "worker" ];
    user = "root";
    volumes = [
      "/var/run/podman/podman.sock:/var/run/docker.sock"
      "/opt/authentik/media:/media"
      "/opt/authentik/certs:/certs"
      "/opt/authentik/custom-templates:/templates"
    ];
    environment = {
      AUTHENTIK_REDIS__HOST = "authentik_redis";
      AUTHENTIK_POSTGRESQL__HOST = "authentik-postgres";
      AUTHENTIK_POSTGRESQL__USER = "authentik";
      AUTHENTIK_POSTGRESQL__NAME = "authentik";
    };
    environmentFiles = [ config.age.secrets.authentik.path ];
    dependsOn = [
      "authentik-postgres"
      "authentik-redis"
    ];
    extraOptions = [
      "--ulimit=nofile=10240:10240"
    ];
    log-driver = "journald";
  };

  systemd.tmpfiles.rules = [
    "d /opt/authentik/media            0755 root root -"
    "d /opt/authentik/certs            0755 root root -"
    "d /opt/authentik/custom-templates 0755 root root -"
  ];
}
