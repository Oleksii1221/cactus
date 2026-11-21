# cactus

Experimental Ubuntu Touch port for the Xiaomi Redmi 6A (`cactus`). The first
bring-up target is Ubuntu Touch 20.04 armhf on Halium 9, using the Android 9
vendor interface and the downstream Linux 4.9 kernel.

This is a development port, not an installable daily-driver image. Do not flash
anything from this repository until the backup and stock-restore gates in
[`docs/PORTING.md`](docs/PORTING.md) have passed.

## Current status

| Area | Status |
| --- | --- |
| Host tools | Android Platform Tools installed; WSL setup in progress |
| Device inventory | Waiting for a phone connected with USB debugging |
| Backup | Not started |
| Bootloader | Unknown; no unlock attempted |
| Halium source configuration | Initial pinned manifest and kernel config added |
| Ubuntu Touch image | Not built or flashed |

The first hardware milestone is Lomiri with display, touch and USB networking.
Telephony, audio, Wi-Fi, Bluetooth, GPS, cameras, sensors and power management
are later bring-up stages and are not claimed to work.

## Quick start

1. Read [`docs/PORTING.md`](docs/PORTING.md).
2. On Windows, run `scripts/windows/Get-CactusInventory.ps1` after enabling USB
   debugging on the phone.
3. Back up shared storage with `scripts/windows/Backup-CactusUserData.ps1`.
4. Verify the backup with `scripts/windows/Verify-CactusBackup.ps1`.
5. Only after the backup and stock restore package are verified, prepare the
   Halium tree using `scripts/linux/prepare-halium.sh` inside the dedicated WSL
   distribution stored on drive D.

## Branches

- `dev` contains active development work and frequent restore points.
- `master` contains only verified release versions. Release commits use version-only messages such as `V1.0.0`.

## Local configuration and private data

This is a public repository. Real credentials, personal data, private network details, access tokens, session files, and other sensitive values must not be committed.

When the project needs local configuration:

1. Copy the provided example file, such as `.env.example`, to its local counterpart, such as `.env`.
2. Replace placeholders such as `YOUR_API_TOKEN` or `YOUR_DEVICE_IP` with local values.
3. Keep the completed local file untracked. Do not commit it.

Device dumps, extracted firmware and local build trees belong under
`D:\CactusBack` and must never be committed.

## Local backup directory

Backups, large files, and temporarily unused project material are stored outside the repository in `D:\CactusBack`. Nothing from that directory should be committed or pushed to GitHub.

## Upstream references

- [UBports porting documentation](https://docs.ubports.com/en/latest/porting/)
- [Halium 9](https://github.com/Halium/android/tree/halium-9.0)
- [Archived Redmi 6A LineageOS device tree](https://github.com/xiaomi-mt6765/android_device_xiaomi_cactus)
- [Xiaomi MT6765 kernel](https://github.com/xiaomi-mt6765/android_kernel_xiaomi_mt6765)
- [Redmi 6A postmarketOS research](https://github.com/UlinProject/redmi6a-postmarketos)
