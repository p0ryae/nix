## First-Time Install Guide (LUKS + TPM + Secure Boot / lanzaboote)

This documents the full reinstall process for hosts in this flake (e.g. `zenbook`, `b550f`) using `disko` for disk provisioning, LUKS full-disk encryption, TPM2 auto-unlock, and `lanzaboote` for Secure Boot with automatic key generation/enrollment.

## Prerequisites

It is highly recommended that you clone this repository, and look through everywhere to understand, AND rename to your own username where necessary.

- NixOS live ISO (minimal ISO is fine + manual `flakes` & `nix-command` enable )
- Target host's `hosts/<host>/disko.nix` disk device path verified against the actual machine. You should make your own.
- This flake repo, cloned with submodules

## Boot the live ISO

```bash
git clone --recurse-submodules https://github.com/p0ryae/nix
cd nix
```

## Confirm the target disk

```bash
lsblk -f
```

Check the device path matches `disko.devices.disk.main.device` in `hosts/<host>/disko.nix`. **Getting this wrong wipes the wrong drive which would be catastrophic!**

## Reset Secure Boot keys in BIOS

If this machine previously had lanzaboote/Secure Boot enrolled, old PK/KEK/db keys likely still live in UEFI NVRAM even after the disk is wiped (Secure Boot state is firmware-side, not disk-side).

In BIOS/UEFI settings, find and use:
- "Clear Secure Boot Keys" / "Reset to Setup Mode" / "Delete all Secure Boot variables"

## Wipe, partition, format, and mount via disko

```bash
sudo nix run github:nix-community/disko -- \
  --mode disko \
  --flake ".#<host>"
```

- Confirm the destructive prompt with `YES`
- Set a LUKS passphrase interactively when prompted. Take note of it somewhere. If you lose it, there is no way to recover the disk.

## Install NixOS

```bash
sudo nixos-install --flake .#<host>
```

Accept the inputs if prompted. Stay patient for everything to install. Set the root password when prompted.

Once everything is done, do:

`sudo reboot`

Remove the install media during restart.

## First boot

1. Enter the LUKS passphrase
2. Log in
3. In the background: `generate-sb-keys.service` creates Secure Boot keys at `pkiBundle`, then `prepare-sb-auto-enroll.service` stages them on the ESP and re-signs boot artifacts
4. The system should reboot itself once staging completes. This is expected and not an error!

## Second boot

`systemd-boot` enrolls the staged keys into firmware on this boot (`secure-boot-enroll = force` is set automatically). Enter the LUKS passphrase again.

Verify:

```bash
bootctl status      # should show Secure Boot: enabled (user)
sbctl status
sudo sbctl verify
```

`sbctl verify` should show all ESP files as signed. If `/boot/EFI/BOOT/BOOTX64.EFI` shows unsigned, check which boot entry your firmware actually uses (`bootctl status` → `Boot Loaders:`); if it's the fallback path, fix it with:

```bash
sudo cp /boot/EFI/systemd/systemd-bootx64.efi /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl verify
```

## Enable Secure Boot enforcement in BIOS

Reboot into UEFI settings, enable Secure Boot, save, reboot again to confirm a clean boot with enforcement active.

## TPM auto-unlock enrollment

```bash
lsblk -f   # confirm actual partition name/number for root
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2   # nvme0n1p2 is the root disk
```

Reboot once more to confirm TPM auto-unlock works without a passphrase prompt. You are officially done.
