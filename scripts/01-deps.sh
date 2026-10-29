#!/usr/bin/env bash
# Install Android/PixelOS build dependencies inside WSL Ubuntu (robust variant).
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "=== apt-get update ==="
apt-get update -qq || { echo "APT UPDATE FAILED"; exit 1; }

CANDIDATES="bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs \
gnupg gperf imagemagick lib32z1-dev libelf-dev lz4 libsdl1.2-dev libssl-dev libxml2-utils \
lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python3 \
python-is-python3 openjdk-21-jdk-headless unzip device-tree-compiler cpio kmod dwarves \
libncurses-dev libtinfo6 aria2 jq tree file"

AVAIL=""
for p in $CANDIDATES; do
  c=$(apt-cache policy "$p" 2>/dev/null | grep -m1 'Candidate:' | awk '{print $2}')
  if [ -n "$c" ] && [ "$c" != "(none)" ]; then
    AVAIL="$AVAIL $p"
  else
    echo "SKIP (no candidate): $p"
  fi
done

echo "=== installing:$AVAIL ==="
apt-get install -y -qq $AVAIL
rc=$?
echo "apt exit=$rc"

echo "=== verify ==="
for t in git python3 java ccache make gcc g++ repo unzip lz4 dtc; do
  printf '%-8s ' "$t"
  command -v "$t" || echo MISSING
done
java -version 2>&1 | head -3
echo "=== done ==="
