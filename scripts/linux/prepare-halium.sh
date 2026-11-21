#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
build_root="${CACTUS_BUILD_ROOT:-$HOME/build/halium-9}"
jobs="${CACTUS_SYNC_JOBS:-4}"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This script must run inside Linux/WSL." >&2
  exit 1
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  adb bc bison build-essential ca-certificates cpio curl flex g++-multilib \
  gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev \
  lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev \
  libxml2 libxml2-utils lzop openjdk-8-jdk python2 python3 rsync schedtool squashfs-tools \
  unzip wget x11proto-core-dev xsltproc zip zlib1g-dev

mkdir -p "$HOME/.local/bin" "$build_root"
if ! command -v python >/dev/null 2>&1; then
  ln -sf /usr/bin/python2 "$HOME/.local/bin/python"
fi
if [[ ! -x "$HOME/.local/bin/repo" ]]; then
  curl -fL https://storage.googleapis.com/git-repo-downloads/repo -o "$HOME/.local/bin/repo"
  chmod 0755 "$HOME/.local/bin/repo"
fi
export PATH="$HOME/.local/bin:$PATH"

cd "$build_root"
if [[ ! -d .repo ]]; then
  repo init -u https://github.com/Halium/android -b halium-9.0 --depth=1
fi
mkdir -p .repo/local_manifests
cp "$repo_root/manifests/xiaomi_cactus.xml" .repo/local_manifests/xiaomi_cactus.xml
repo sync -c --no-clone-bundle --no-tags -j"$jobs"

kernel_dir="$build_root/kernel/xiaomi/mt6765"
patch="$repo_root/patches/kernel/0001-add-minimal-halium-config.patch"
if git -C "$kernel_dir" apply --check "$patch" 2>/dev/null; then
  git -C "$kernel_dir" apply "$patch"
elif ! git -C "$kernel_dir" apply --reverse --check "$patch" 2>/dev/null; then
  echo "Kernel patch is neither applicable nor already applied." >&2
  exit 1
fi

if [[ -x hybris-patches/apply-patches.sh ]]; then
  hybris-patches/apply-patches.sh --mb
fi

echo "Halium source prepared at $build_root"
echo "Next: extract proprietary files locally with scripts/linux/extract-vendor.sh"
