{ ... }:
{
  services.fprintd.enable = true;

  home-manager.sharedModules = [
    {
      wayland.windowManager.sway.config.output."*".scale = "1.65";
    }
  ];
}
