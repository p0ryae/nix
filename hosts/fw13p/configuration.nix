{
  config,
  lib,
  inputs,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.mesa-git-nix.nixosModules.default
  ];
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "rtsx_pci_sdmmc"
    "lz4"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "nvme.noacpi=1"
    "hibernate.compressor=lz4"
  ];
  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [
    "tpm2-device=auto"
    "tpm2-pcrs=7"
    "tpm2-pin=yes"
    "tpm2-measure-pcr=yes"
    "no-read-workqueue"
    "no-write-workqueue"
  ];
  boot.blacklistedKernelModules = [ "cros-usbpd-charger" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs = {
    overlays = [
      inputs.mesa-git-nix.overlays.default
    ];
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };
  mesa-git = {
    enable = true;
    drivers = [
      "intel"
    ];
  };
  hardware.acpilight.enable = lib.mkDefault true;

  services.udev.extraRules = ''
    # Fix headphone noise when on powersave
    # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
    SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"

    # Prevent Framework 13 Goodix Fingerprint Reader (27c6:609c) from autosuspending
    SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="609c", ATTR{power/control}="on"
  '';

  services.fprintd.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];

  services.scx = {
    scheduler = lib.mkForce "scx_bpfland";
    extraArgs = lib.mkForce [
      "--primary-domain"
      "performance"
      "--preferred-idle-scan"
      "--slice-us-lag"
      "20000"
    ];
  };

  environment.systemPackages = with pkgs; [
    fw-ectool
    framework-tool
  ];

  security.wrappers.btop = {
    source = "${pkgs.btop}/bin/btop";
    capabilities = "cap_perfmon=ep";
    owner = "root";
    group = "root";
  };

  home-manager.sharedModules = [
    {
      wayland.windowManager.sway.config.output."*".scale = "1.5";
    }
  ];
}
