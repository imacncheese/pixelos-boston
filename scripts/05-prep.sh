#!/usr/bin/env bash
# Build-host preparation: swap, ccache, java env.
set -uo pipefail

if ! swapon --show | grep -q /swapfile; then
  if [ ! -f /swapfile ]; then
    echo "creating 16G swapfile"
    fallocate -l 16G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=16384 status=none
    chmod 600 /swapfile
    mkswap /swapfile >/dev/null
  fi
  swapon /swapfile && echo "swap enabled"
fi

mkdir -p /root/.ccache
ccache --set-config=max_size=60G 2>/dev/null || true
ccache -s 2>/dev/null | head -12

echo "=== memory ==="
free -h
echo "=== disk ==="
df -h / | tail -1
echo "=== java ==="
java -version 2>&1 | head -2
