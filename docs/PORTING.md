# Redmi 6A Ubuntu Touch porting runbook

## Safety gates

The Redmi 6A is not an officially supported UBports device. This project must
not use the UBports Installer or flash an image intended for `cereus` (Redmi 6).
The shared MT6765 platform does not make those images interchangeable.

Do not unlock or write any partition until all of these conditions are true:

1. USB identity confirms `ro.product.device=cactus`.
2. User files have been copied to `D:\CactusBack`.
3. Backup hashes have been generated and verified.
4. Critical modem/calibration partitions have two verified local copies, or the
   work stops for an explicit reassessment.
5. The exact stock MIUI fastboot package is available and its checksum is
   recorded.
6. The stock restore procedure uses `clean all`, never `clean all and lock`.

Mi Unlock erases user data and may impose an account waiting period. Unlocking
is a later hardware step; none of the repository setup performs it.

## Host layout

- Public source repository: `%USERPROFILE%\Documents\PycharmProjects\cactus`
- Private backups and downloads: `D:\CactusBack`
- WSL virtual disk: `D:\CactusBack\wsl\CactusUbuntu`
- Halium checkout inside WSL: `/home/cactus/build/halium-9`

The build checkout must live inside the WSL ext4 virtual disk. Building Android
directly under `/mnt/c` or `/mnt/d` is unsupported because NTFS semantics and
case handling can break the build.

## Stage 1: inventory and user-data backup

Enable Developer options and USB debugging on stock MIUI, connect the phone,
accept the RSA prompt, and run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/windows/Get-CactusInventory.ps1
powershell -ExecutionPolicy Bypass -File scripts/windows/Backup-CactusUserData.ps1
powershell -ExecutionPolicy Bypass -File scripts/windows/Verify-CactusBackup.ps1
```

The inventory is private because it can contain serial numbers and build
identifiers. It is written only under `D:\CactusBack`.

A raw eMMC/partition backup is deliberately not automated yet. It must be
implemented only after the exact preloader/security state is identified; using
an incorrect MediaTek download agent can damage calibration data. The first
inventory records enough information to select a read-only method.

## Stage 2: stock recovery proof

Download the fastboot package matching the installed Android 9/MIUI build.
Record its source URL and SHA-256 in the private backup directory. Inspect the
flash scripts before use and exclude every command that locks the bootloader.

After the official unlock completes, perform one controlled stock restore and
verify display, touch, Wi-Fi, modem and fastboot access. Only then continue to
Ubuntu Touch.

## Stage 3: Halium build

The initial source baseline is pinned in `manifests/xiaomi_cactus.xml`:

- LineageOS 16.0 device tree for `cactus`;
- MT6765 common tree and 32-bit Android userspace;
- MT6765 Linux 4.9 kernel;
- Lineage device settings.

Proprietary files are not fetched by the manifest. After syncing the source,
extract them locally from the connected stock system or an unpacked stock ROM:

```bash
scripts/linux/prepare-halium.sh
scripts/linux/extract-vendor.sh adb
scripts/linux/build-halium.sh
```

The first build target is `halium-boot` plus the device-specific system image.
Ubuntu Touch 20.04 armhf rootfs/GSI artifacts must be downloaded from UBports
and checksum-verified at installation time; they are never committed here.

## Stage 4: first boot and rollback

Prefer `fastboot boot` for a compatible recovery. If the bootloader does not
support temporary recovery boot, flashing recovery is the first persistent
write and must happen only after the safety gates pass.

The first prototype is successful only when:

- the kernel reaches userspace without a reboot loop;
- Lomiri renders at 720x1440;
- display, backlight and touch respond;
- ADB or SSH is reachable over USB;
- fastboot/recovery remains accessible;
- the phone has no uncontrolled heat or battery drain.

Stop and return to stock immediately on repeated watchdog resets, missing eMMC,
loss of fastboot/recovery access, or abnormal heat. Telephony and the other
peripherals are intentionally outside the first-boot acceptance gate.

## Publication rules

Only source, patches, manifests, scripts, documentation and sanitized logs may
be published. Never publish partition images, proprietary blobs, serials,
IMEIs, Wi-Fi data, Mi account information or raw logs containing identifiers.
