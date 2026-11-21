#!/usr/bin/env bash
set -euo pipefail

build_root="${CACTUS_BUILD_ROOT:-$HOME/build/halium-9}"
source_path="${1:-adb}"

cd "$build_root"
for tree in device/xiaomi/mt6765-common device/xiaomi/cactus; do
  if [[ ! -x "$tree/extract-files.sh" ]]; then
    echo "Missing extractor: $tree/extract-files.sh" >&2
    exit 1
  fi
  "$tree/extract-files.sh" "$source_path"
done

echo "Vendor files were extracted only into the local Halium tree."
echo "Do not copy vendor/xiaomi into the public cactus repository."
