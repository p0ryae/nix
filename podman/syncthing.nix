{
  virtualisation.oci-containers.containers.syncthing = {
    image = "lscr.io/linuxserver/syncthing:latest";
    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Etc/UTC";
    };
    ports = [
      "8384:8384/tcp" # Web GUI
      "22000:22000/tcp" # Sync protocol (TCP)
      "22000:22000/udp" # Sync protocol (UDP)
      "21027:21027/udp" # Protocol discovery
    ];
    volumes = [
      "/opt/syncthing/config:/config:rw"
      "/opt/syncthing/data1:/data1:rw"
      "/opt/syncthing/data2:/data2:rw"
    ];
    extraOptions = [ "--hostname=syncthing" ];
    log-driver = "journald";
  };

  systemd.tmpfiles.rules = [
    "d /opt/syncthing/config 0755 root root -"
    "d /opt/syncthing/data1  0755 1000 1000 -"
    "d /opt/syncthing/data2  0755 1000 1000 -"
  ];
}
