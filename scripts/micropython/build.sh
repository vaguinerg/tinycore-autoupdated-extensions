echo http://mirror.math.princeton.edu/pub/tinycorelinux/ > /opt/tcemirror
MARCH="$1"

if [ -z "$MARCH" ]; then
  echo "Missing -march argument"
  exit 1
fi

echo "Building with -march=$MARCH"

sudo rm -f /bin/uname
echo '#!/bin/busybox ash
case "$1" in
  -r)
    echo "6.12.11-tinycore64"
    ;;
  -m)
    echo "x86_64"
    ;;
  -s)
  echo "Linux"
  ;;
  -v)
  echo "#1 SMP Sun Jan 26 16:50:13 UTC 2025"
  ;;
  *)
    echo "6.12.11-tinycore64"
    ;;
esac' | sudo tee /bin/uname > /dev/null
sudo chmod +x /bin/uname
tce-load -lwi compiletc libffi-dev python3.9 squashfs-tools jq upx submitqc curl sstrip libffi-dev openssl

workdir=$(mktemp -d)
cd $workdir
version=1.25.0

wget --no-check-certificate -O- https://github.com/micropython/micropython/releases/download/v$version/micropython-$version.tar.xz | tar -xJ
cd micropython-$version/ports/unix/
sed -i '/^COPT ?= -Os$/d' Makefile
sed -i 's/-Os//g' Makefile

#for some reason, the first make with cflags causes error. you need to compile with just "make" then pass the flags
make
make clean
LDFLAGS="-Wl,-O2,--as-needed,--sort-common -flto -fuse-linker-plugin" CFLAGS="-fopt-info-vec-optimized -fmerge-all-constants -fno-semantic-interposition -ftree-vectorize -fipa-pta -funroll-loops -floop-nest-optimize -Ofast -march=$MARCH -flto" CXXFLAGS="-fopt-info-vec-optimized -fmerge-all-constants -fno-semantic-interposition -ftree-vectorize -fipa-pta -funroll-loops -floop-nest-optimize -Ofast -march=$MARCH -flto" make V=1 -j4
bindir=$(mktemp -d)
mkdir -p $bindir/usr/local/bin/
mv build-standard/micropython $bindir/usr/local/bin/
sstrip -z $bindir/usr/local/bin/micropython
mksquashfs $bindir micropython.tcz
sudo submitqc --nonet --blocksize=65536 micropython.tcz
mv -f micropython.tcz /output
