{ ... }:
{
  virtualisation.oci-containers.containers."vaultwarden" = {
    image = "vaultwarden/server:latest";
    ports = [ "4444:80/tcp" ];
    volumes = [ "/opt/vaultwarden/data:/data:rw" ];
    environment = {
      DOMAIN = "https://vw.porya.me/";
      # ADMIN_TOKEN = "";
    };
    log-driver = "journald";
  };
}
