#!/usr/bin/env bash
# Initialize the PixelOS source tree (Android 16 QPR2 branch) with boston device trees.
set -uo pipefail
export PATH=/usr/local/bin:$PATH
export GIT_LFS_SKIP_SMUDGE=0

SRC=/root/pixelos
mkdir -p "$SRC"
cd "$SRC" || exit 1

if [ ! -d .repo ]; then
  echo "=== repo init ==="
  repo init -u https://github.com/PixelOS-AOSP/android_manifest -b sixteen-qpr2 \
      --depth=1 --git-lfs --no-clone-bundle || { echo "REPO INIT FAILED"; exit 1; }
else
  echo "=== .repo exists, skipping init ==="
fi

echo "=== manifest projects of interest ==="
grep -E 'device/lineage|vendor/lineage|vendor/pixelos|hardware/lineage|device/qcom/sepolicy' .repo/manifests/default.xml || echo "(none matched)"

echo "=== manifest default revision ==="
grep -m2 'default revision' .repo/manifests/default.xml
