#!/usr/bin/env bash
# Launch the PixelOS boston build detached so it survives the caller.
set -o pipefail

cat > /root/build-run.sh <<'EOS'
#!/usr/bin/env bash
cd /root/pixelos || exit 1
export PATH=/usr/local/bin:$PATH
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=/root/.ccache
export CCACHE_COMPRESS=1
export LC_ALL=C
export ALLOW_MISSING_DEPENDENCIES=true

echo "=== build start $(date -u) ==="
source build/envsetup.sh
lunch custom_boston-bp4a-user
echo "=== mka pixelos -j12 $(date -u) ==="
mka pixelos -j12
rc=$?
echo "=== BUILD_EXIT=$rc $(date -u) ==="
ls -lh out/target/product/boston/*.zip 2>/dev/null
EOS
chmod +x /root/build-run.sh

# Detach from this shell's session so the build keeps running.
setsid nohup /root/build-run.sh > /root/pixelos-build.log 2>&1 < /dev/null &
sleep 20
echo "=== first log lines ==="
tail -20 /root/pixelos-build.log
