{ self, config, ... }:
{
  age.secrets."authentik".file = "${self}/secrets/authentik.age";

  systemd.tmpfiles.rules = [
    "d /opt/authentik/media            0755 root root -"
    "d /opt/authentik/certs            0755 root root -"
    "d /opt/authentik/custom-templates 0755 root root -"
  ];

  systemd.services.create-authentik-network = {
    description = "Create authentik-net Docker network";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [
      "docker-authentik_server.service"
      "docker-authentik_worker.service"
      "docker-authentik_redis.service"
      "docker-authentik_postgres.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      Environment = "PATH=/run/current-system/sw/bin";
      RemainAfterExit = true;
    };
    script = ''
      docker network inspect authentik-net &>/dev/null \
        || docker network create authentik-net
    '';
  };

  virtualisation.oci-containers.containers."authentik_postgres" = {
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
      "--network=authentik-net"
      "--health-cmd=pg_isready -d authentik -U authentik"
      "--health-start-period=20s"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-timeout=5s"
    ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers."authentik_redis" = {
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
      "--network=authentik-net"
      "--health-cmd=redis-cli ping | grep PONG"
      "--health-start-period=20s"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-timeout=3s"
    ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers."authentik_server" = {
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
      AUTHENTIK_REDIS__HOST = "authentik_redis";
      AUTHENTIK_POSTGRESQL__HOST = "authentik_postgres";
      AUTHENTIK_POSTGRESQL__USER = "authentik";
      AUTHENTIK_POSTGRESQL__NAME = "authentik";
    };
    environmentFiles = [ config.age.secrets.authentik.path ];
    dependsOn = [
      "authentik_postgres"
      "authentik_redis"
    ];
    extraOptions = [ "--network=authentik-net" ];
    log-driver = "journald";
  };

  virtualisation.oci-containers.containers."authentik_worker" = {
    image = "ghcr.io/goauthentik/server:2025.6.4";
    cmd = [ "worker" ];
    user = "root";
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/opt/authentik/media:/media"
      "/opt/authentik/certs:/certs"
      "/opt/authentik/custom-templates:/templates"
    ];
    environment = {
      AUTHENTIK_REDIS__HOST = "authentik_redis";
      AUTHENTIK_POSTGRESQL__HOST = "authentik_postgres";
      AUTHENTIK_POSTGRESQL__USER = "authentik";
      AUTHENTIK_POSTGRESQL__NAME = "authentik";
    };
    environmentFiles = [ config.age.secrets.authentik.path ];
    dependsOn = [
      "authentik_postgres"
      "authentik_redis"
    ];
    extraOptions = [
      "--network=authentik-net"
      "--ulimit=nofile=10240:10240"
    ];
    log-driver = "journald";
  };
}
