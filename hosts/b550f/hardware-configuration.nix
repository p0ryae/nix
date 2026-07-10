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
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  boot.kernelModules = [
    "kvm-amd"
    "kvmfr"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  boot.kernelParams = [
    "kvmfr.static_size_mb=64"
    "iommu=pt"
    "amd_iommu=on"
  ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  fileSystems."/mnt/nvme1" = {
    device = "/dev/disk/by-partuuid/367c3a3f-de9c-44e0-a672-05547055d572";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [
    "tpm2-device=auto"
    "tpm2-pcrs=7"
    "tpm2-pin=yes"
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
