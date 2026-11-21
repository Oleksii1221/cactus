#!/usr/bin/env bash
set -euo pipefail

build_root="${CACTUS_BUILD_ROOT:-$HOME/build/halium-9}"
jobs="${CACTUS_BUILD_JOBS:-$(nproc)}"

cd "$build_root"
if [[ ! -d vendor/xiaomi ]]; then
  echo "Local proprietary files are missing. Run extract-vendor.sh first." >&2
  exit 1
fi

# shellcheck source=/dev/null
source build/envsetup.sh
breakfast cactus
mka -j"$jobs" halium-boot systemimage

echo "Build outputs:"
find out/target/product/cactus -maxdepth 1 -type f \
  \( -name 'halium-boot.img' -o -name 'system.img' \) -print
