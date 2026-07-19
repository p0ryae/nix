let
  porya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH63CtZES26bDsxCJ5SJ6loEZPtqi1MzfQpGkJRAMban porya@b550f";
  b550f = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINqmEjpvUsAkfpIwWNmDM7J5u6YdlSFojnPPKwpn4Pc6 root@b550f";
  rpi5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWsES0B27Az+zHHH8sanRt+QkHiiTO8CkDUR3IOcmJ3 root@rpi5";
in
{
  "wifi.age".publicKeys = [
    porya
    b550f
    rpi5
  ];
  "immich.age".publicKeys = [
    porya
    rpi5
  ];
  "authentik.age".publicKeys = [
    porya
    rpi5
  ];
}
