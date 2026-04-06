{
  config,
  lib,
  pkgs,
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
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/luks-534fa6d6-33a8-4511-a44d-eb10667e6906";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-534fa6d6-33a8-4511-a44d-eb10667e6906" = {
    device = "/dev/disk/by-uuid/534fa6d6-33a8-4511-a44d-eb10667e6906";
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pcrs=7"
      "tpm2-pin=yes"
    ];
  };

  boot.initrd.luks.devices."luks-b7e7e604-d75f-4655-9655-e376db582a4c" = {
    device = "/dev/disk/by-uuid/b7e7e604-d75f-4655-9655-e376db582a4c";
    crypttabExtraOpts = [
      "tpm2-device=auto"
      "tpm2-pcrs=7"
    ];
  };

  fileSystems."/nix/store" = {
    device = "/nix/store";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B80A-6285";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/mapper/luks-b7e7e604-d75f-4655-9655-e376db582a4c"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
