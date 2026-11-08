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
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  nixpkgs = {
    overlays = [
      inputs.mesa-git-nix.overlays.default
    ];
    config.rocmSupport = true;
  };

  boot.kernelModules = [
    "kvm-amd"
    "kvmfr"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.kvmfr
    # (config.boot.kernelPackages.callPackage ./cpuid_fault_emulation { })
  ];
  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xffffffff"
    # "pcie_acs_override=downstream,multifunction"
    "kvmfr.static_size_mb=64"
    "iommu=pt"
    "amd_iommu=on"
    "pcie_aspm=off"
    "pcie_port_pm=off"
    # "clearcpuid=umip"
  ];

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
  mesa-git = {
    enable = true;
    drivers = [
      "amd"
    ];
  };

  home-manager.sharedModules = [
    {
      wayland.windowManager.sway.config = {
        startup = [
          { command = "${pkgs.wl-gammactl}/bin/wl-gammactl -c 1.0 -b 1.0 -g 1.0"; }
        ];
        output."DP-2" = {
          color_profile = lib.mkForce "icc ${./27GP83B-B.icm}";
        };
      };
    }
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];
}
