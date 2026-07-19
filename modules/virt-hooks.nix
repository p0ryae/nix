{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.custom.virtHooks;

  qemuHookDispatcher = pkgs.writeShellScript "libvirt-qemu-hook" ''
    GUEST_NAME="$1"
    HOOK_NAME="$2"
    STATE_NAME="$3"

    BASEDIR="$(dirname "$0")"
    HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

    if [ -f "$HOOKPATH" ]; then
      exec "$HOOKPATH" "$@"
    fi
  '';

  mkBindScript =
    vm:
    pkgs.writeShellScript "bind-vfio-${vm.name}" ''
      set -x
      gpu="${vm.gpuAddress}"
      aud="${vm.audioAddress}"
      gpu_vd="$(cat /sys/bus/pci/devices/$gpu/vendor) $(cat /sys/bus/pci/devices/$gpu/device)"
      aud_vd="$(cat /sys/bus/pci/devices/$aud/vendor) $(cat /sys/bus/pci/devices/$aud/device)"

      modprobe vfio-pci

      echo "$gpu" > "/sys/bus/pci/devices/$gpu/driver/unbind" 2>/dev/null
      echo "$aud" > "/sys/bus/pci/devices/$aud/driver/unbind" 2>/dev/null

      echo "$gpu_vd" > /sys/bus/pci/drivers/vfio-pci/new_id
      echo "$aud_vd" > /sys/bus/pci/drivers/vfio-pci/new_id
    '';

  mkUnbindScript =
    vm:
    pkgs.writeShellScript "unbind-vfio-${vm.name}" ''
      set -x
      gpu="${vm.gpuAddress}"
      aud="${vm.audioAddress}"
      gpu_vd="$(cat /sys/bus/pci/devices/$gpu/vendor) $(cat /sys/bus/pci/devices/$gpu/device)"
      aud_vd="$(cat /sys/bus/pci/devices/$aud/vendor) $(cat /sys/bus/pci/devices/$aud/device)"

      echo "$gpu_vd" > /sys/bus/pci/drivers/vfio-pci/remove_id
      echo "$aud_vd" > /sys/bus/pci/drivers/vfio-pci/remove_id

      echo 1 > "/sys/bus/pci/devices/$gpu/remove"
      echo 1 > "/sys/bus/pci/devices/$aud/remove"

      echo 1 > "/sys/bus/pci/rescan"
    '';

  vmSubmodule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "libvirt domain name (must match <name> in the VM's XML)";
      };
      gpuAddress = mkOption {
        type = types.str;
        example = "0000:0d:00.0";
        description = "PCI address of the GPU function";
      };
      audioAddress = mkOption {
        type = types.str;
        example = "0000:0d:00.1";
        description = "PCI address of the GPU's HD audio function";
      };
    };
  };

  mkVmActivation = vm: ''
    mkdir -p /var/lib/libvirt/hooks/qemu.d/${vm.name}/prepare/begin
    mkdir -p /var/lib/libvirt/hooks/qemu.d/${vm.name}/release/end

    ln -sf ${mkBindScript vm} /var/lib/libvirt/hooks/qemu.d/${vm.name}/prepare/begin/bind_vfio.sh
    ln -sf ${mkUnbindScript vm} /var/lib/libvirt/hooks/qemu.d/${vm.name}/release/end/unbind_vfio.sh
  '';
in
{
  options.custom.virtHooks = {
    enable = mkEnableOption "dynamic VFIO bind/unbind libvirt qemu hooks";

    vms = mkOption {
      type = types.listOf vmSubmodule;
      default = [ ];
      description = "VMs to generate dynamic vfio-pci bind/unbind hooks for";
      example = [
        {
          name = "win11";
          gpuAddress = "0000:0d:00.0";
          audioAddress = "0000:0d:00.1";
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.libvirtQemuHooks = ''
      mkdir -p /var/lib/libvirt/hooks
      ln -sf ${qemuHookDispatcher} /var/lib/libvirt/hooks/qemu
      ${concatStringsSep "\n" (map mkVmActivation cfg.vms)}
    '';
  };
}
