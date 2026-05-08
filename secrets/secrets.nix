let
  porya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQQt3NnHVW0bFJd427d0/7QxTshKX8T74rGzcG9lKRo porya@b550f";
  b550f = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMv4/E9BT4FlGDY+Aszaf4F4MRPRT51Bb/2jaSSlOmz/ root@b550f";
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
