#!/usr/bin/env bash
# Build PixelOS for boston. Usage: 06-build.sh [lunch-target] [jobs]
set -uo pipefail
TARGET="${1:-lineage_boston-user}"
JOBS="${2:-14}"

cd /root/pixelos || exit 1
export PATH=/usr/local/bin:$PATH
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=/root/.ccache
export CCACHE_COMPRESS=1
export LC_ALL=C
export ALLOW_MISSING_DEPENDENCIES=true

echo "=== ccache ==="
ccache -s | head -8

echo "=== envsetup ==="
source build/envsetup.sh >/dev/null 2>&1 || { echo "ENVSETUP FAILED"; exit 1; }

echo "=== available products (boston) ==="
lunch 2>/dev/null | grep -i "boston" | head -5 || true

echo "=== lunch $TARGET ==="
lunch "$TARGET" || { echo "LUNCH FAILED for $TARGET"; exit 1; }

echo "=== building ($JOBS jobs) $(date -u) ==="
mka bacon -j"$JOBS" 2>&1 | tee /root/pixelos-build.log
rc=${PIPESTATUS[0]}
echo "BUILD_EXIT=$rc $(date -u)"
echo "=== artifacts ==="
ls -lh out/target/product/boston/*.zip out/target/product/boston/*.img 2>/dev/null | tail -20
exit $rc
