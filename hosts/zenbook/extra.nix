{ ... }: {
  services.fprintd.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  home-manager.sharedModules = [
    {
      wayland.windowManager.sway.config.output."*".scale = "1.65";
    }
  ];
}
