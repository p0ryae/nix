{
  config,
  lib,
  # pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems."/" = {
    device = "/dev/mapper/luks-7096d3cf-2452-43c6-9e17-09a083a08bf8";
    fsType = "ext4";
  };

  fileSystems."/mnt/nvme1" = {
    device = "/dev/disk/by-partuuid/367c3a3f-de9c-44e0-a672-05547055d572";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  boot.initrd.luks.devices."luks-7096d3cf-2452-43c6-9e17-09a083a08bf8" = {
    device = "/dev/disk/by-uuid/7096d3cf-2452-43c6-9e17-09a083a08bf8";
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pcrs=7"
    ];
  };

  boot.initrd.luks.devices."luks-c54a9405-80b3-4177-a43d-1a3c87c07aec" = lib.mkForce {
    device = "/dev/disk/by-uuid/c54a9405-80b3-4177-a43d-1a3c87c07aec";
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pcrs=7"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4C0F-139A";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/mapper/luks-c54a9405-80b3-4177-a43d-1a3c87c07aec"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.i2c.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = "true";
      };
    };
  };
  hardware.wooting.enable = true;
}
