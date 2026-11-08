{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-gaming.nixosModules.platformOptimizations
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.spicetify-nix.nixosModules.spicetify
    ./virt-hooks.nix
  ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelModules = [ "bfq" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  hardware.block.scheduler = {
    "nvme[0-9]*" = "bfq";
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.helium.overlays.default
      (final: prev: {
        tela-circle-icon-theme = prev.tela-circle-icon-theme.overrideAttrs {
          dontCheckForBrokenSymlinks = true;
        };
      })
    ];
  };

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
    "wireshark"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    vazirmatn
    nerd-fonts.jetbrains-mono
    inter
    corefonts
    vista-fonts
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
    llama-cpp-vulkan
    vesktop
    caligula
    dnsmasq
    packet
    helium
    widevine-cdm
    swtpm
    openconnect
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
    libreoffice-stable
    hunspell
    hunspellDicts.en_US
    jdk
    gdb
    valgrind
    wireshark
    deskflow
  ];

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
    gamemode.enable = true;
    virt-manager.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
      ];
    };
    wireshark.enable = true;
    spicetify = {
      enable = true;
      enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system}.extensions; [
        adblockify
        hidePodcasts
        shuffle
      ];
    };
  };

  services = {
    displayManager.ly.enable = true;
    gnome = {
      gnome-keyring.enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      lowLatency = {
        enable = true;
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
    scx-loader = {
      enable = true;
      config = {
        default_sched = "scx_lavd";
        default_mode = "Auto";

        scheds.scx_lavd = {
          auto_mode = [
            "--performance"
            "--pinned-slice-us"
            "500"
          ];
        };
      };
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      settings = {
        publish = {
          "disable-publishing" = false;
          "publish-workstation" = true;
          "publish-addresses" = true;
        };
      };
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

  security = {
    rtkit.enable = true;
    pam.services = {
      sudo.fprintAuth = true;
      polkit-1.fprintAuth = true;
      login.fprintAuth = true;
      ly.fprintAuth = true;
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
