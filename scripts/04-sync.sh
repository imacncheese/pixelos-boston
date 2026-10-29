#!/usr/bin/env bash
# Sync the PixelOS source tree plus the boston device/kernel/vendor trees.
set -uo pipefail
export PATH=/usr/local/bin:$PATH
cd /root/pixelos || exit 1

mkdir -p .repo/local_manifests
cp /mnt/f/dsh/pixelos/boston-local-manifest.xml .repo/local_manifests/boston.xml

echo "=== local manifest ==="
cat .repo/local_manifests/boston.xml

echo "=== starting repo sync $(date -u) ==="
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags --retry-fetches=5 \
  > /root/pixelos-sync.log 2>&1
rc=$?
echo "SYNC_EXIT=$rc $(date -u)"
tail -40 /root/pixelos-sync.log
exit $rc
