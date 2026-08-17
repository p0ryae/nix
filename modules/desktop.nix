{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.mesa-git-nix.nixosModules.default
    ./virt-hooks.nix
  ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_testing;
    kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
      "pcie_acs_override=downstream,multifunction"
    ];
  };

  nixpkgs = {
    config = {
      # needed for machine learning, LLMs, and btop
      # well... "needed" is a strong word, so maybe preferred
      rocmSupport = true;
      allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "spotify"
          "steam"
          "steam-unwrapped"
          "azure-vpn-client-unwrapped"
          "wootility"
          "widevine-cdm"
        ];
    };
    overlays = [
      inputs.helium.overlays.default
      inputs.mesa-git-nix.overlays.default
      inputs.llama-cpp.overlays.default
      (final: prev: {
        azure-vpn-client-unwrapped = prev.callPackage ./azure-vpn-client/package.nix { };
      })
      (self: super: {
        yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: {
          postPatch = ''
            substituteInPlace yt_dlp/version.py \
              --replace-fail "UPDATE_HINT = None" 'UPDATE_HINT = "Nixpkgs/NixOS likely already contain an updated version.\n       To get it run nix-channel --update or nix flake update in your config directory."'
            ${lib.optionalString true ''
              # deno is required for full YouTube support (since 2025.11.12).
              # This makes yt-dlp find deno even if it is used as a python dependency, i.e. in kodiPackages.sendtokodi.
              # Crafted so people can replace deno with one of the other JS runtimes.
              substituteInPlace yt_dlp/utils/_jsruntime.py \
                --replace-fail "path = _determine_runtime_path(self._path, '${pkgs.nodejs.meta.mainProgram}')" "path = '${lib.getExe pkgs.nodejs}'"
            ''}
          '';
        });
      })
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024;
    }
  ];

  systemd.services = {
    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };

  users.users.porya.extraGroups = lib.mkAfter [
    "i2c"
    "adbusers"
    "libvirtd"
    "kvm"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    vazirmatn
    nerd-fonts.jetbrains-mono
    inter
  ];

  environment.systemPackages = with pkgs; [
    sway
    sway-audio-idle-inhibit
    autotiling-rs
    colord
    grim
    slurp
    wl-clipboard
    sway-contrib.grimshot
    kitty
    nautilus
    file-roller
    swayimg
    mpv
    spotify
    easyeffects
    ddcutil
    wiremix
    tela-circle-icon-theme
    adwaita-icon-theme
    adw-gtk3
    wineWow64Packages.staging
    wineWow64Packages.waylandFull
    winetricks
    protonplus
    protontricks
    android-tools
    imhex
    pdfarranger
    vulkan-tools
    (pkgs.llamaPackages.llama-cpp.override { useVulkan = true; })
    lan-mouse
    wootility
    vesktop
    caligula
    dnsmasq
    packet
    helium
    widevine-cdm
    swtpm
    openconnect
    pciutils
    looking-glass-client
    (pkgs.writeShellScriptBin "enable-hv" ''
      sudo modprobe -r kvm_amd kvm
      sudo modprobe cpuid_fault_emulation
    '')
    (pkgs.writeShellScriptBin "disable-hv" ''
      sudo modprobe -r cpuid_fault_emulation
      sudo modprobe kvm_amd kvm
    '')
    r2modman
    mdbook
    inputs.nanocoder.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  mesa-git = {
    enable = true;
    drivers = [ "amd" ];
  };

  environment.sessionVariables.WLR_RENDERER = "vulkan";

  programs = {
    sway.enable = true;
    seahorse.enable = true;
    steam = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
      enable = true;
      platformOptimizations.enable = true;
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    openvpn3.enable = true;
    virt-manager.enable = true;
    azure-vpn-client.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    };
  };

  services = {
    displayManager.ly.enable = true;
    gnome.gnome-keyring.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
      lowLatency = {
        enable = true;
        quantum = 64;
        rate = 48000;
      };
      wireplumber.extraConfig = {
        "51-dualsense-alsa" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "device.name" = "~alsa_card.usb-Sony_Interactive_Entertainment_DualSense.*";
                }
              ];
              actions = {
                "update-props" = {
                  "api.alsa.use-ucm" = false;
                  "device.profile-set" = "analog-surround-40.conf";
                };
              };
            }
            {
              matches = [
                {
                  "node.name" = "~alsa_output.usb-Sony_Interactive_Entertainment_DualSense.*.analog-surround-40";
                }
              ];
              actions = {
                "update-props" = {
                  "node.description" = "Wireless Controller";
                  "node.nick" = "Wireless Controller";
                  "audio.format" = "S16LE";
                  "audio.rate" = 48000;
                  "node.force-rate" = 48000;
                  "channelmix.disable" = true;
                  "priority.driver" = 1500;
                  "priority.session" = 1500;
                };
              };
            }
          ];
        };
      };
    };
    power-profiles-daemon.enable = true;
    upower.enable = true;
    gvfs.enable = true;
    flatpak.enable = true;
    lact.enable = true;
    syncthing = {
      enable = true;
      user = "porya";
      dataDir = "/home/porya";
    };
    scx = {
      enable = true;
      scheduler = "scx_lavd";
      extraArgs = [
        "--performance"
        "--pinned-slice-us 500"
      ];
    };
    udev.packages = lib.singleton (
      pkgs.writeTextFile {
        name = "kvmfr";
        text = ''
          SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"
        '';
        destination = "/etc/udev/rules.d/70-kvmfr.rules";
      }
    );
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          chooser_type = "simple";
          chooser_cmd = "slurp -f 'Monitor: %o' -or";
        };
      };
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      runAsRoot = true;
      verbatimConfig = ''
        namespaces = []
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
          "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
          "/dev/kvmfr0"
        ]
      '';
    };
  };

  custom.virtHooks = {
    enable = true;
    vms = [
      {
        name = "win11";
        gpuAddress = "0000:04:00.0";
        audioAddress = "0000:04:00.1";
      }
    ];
  };
}
