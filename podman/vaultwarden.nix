{
  virtualisation.oci-containers.containers.vaultwarden = {
    image = "docker.io/vaultwarden/server:latest";
    ports = [ "4444:80/tcp" ];
    volumes = [ "/opt/vaultwarden/data:/data:rw" ];
    environment = {
      DOMAIN = "https://vw.porya.me/";
      # ADMIN_TOKEN = "";
    };
    log-driver = "journald";
    extraOptions = [ "--label=io.containers.autoupdate=registry" ];
  };

  systemd.tmpfiles.rules = [
    "d /opt/vaultwarden/data 0755 root root -"
  ];
}
