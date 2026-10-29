#!/usr/bin/env bash
# Collect build artifacts into the Windows-visible workspace and report their digests.
set -o pipefail
cd /root/pixelos/out/target/product/boston || { echo "no product out dir"; exit 1; }

OUTDIR=/mnt/f/dsh/pixelos/out
mkdir -p "$OUTDIR"

echo "=== artifacts in out/ ==="
ls -lh *.zip *.img 2>/dev/null

ZIP=$(ls -1t PixelOS_*.zip 2>/dev/null | head -1)
if [ -z "$ZIP" ]; then
  echo "NO OTA ZIP FOUND"
  exit 1
fi

echo "=== copying $ZIP and recovery.img ==="
cp -f "$ZIP" "$OUTDIR/"
cp -f "$ZIP.md5sum" "$OUTDIR/" 2>/dev/null
[ -f recovery.img ] && cp -f recovery.img "$OUTDIR/"
[ -f boot.img ] && cp -f boot.img "$OUTDIR/"
[ -f vendor_boot.img ] && cp -f vendor_boot.img "$OUTDIR/"
[ -f dtbo.img ] && cp -f dtbo.img "$OUTDIR/"

cd "$OUTDIR" || exit 1
echo "=== copied ==="
ls -lh
echo "=== sha256 ==="
sha256sum * 2>/dev/null
