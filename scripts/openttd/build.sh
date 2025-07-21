echo http://mirror.math.princeton.edu/pub/tinycorelinux/ > /opt/tcemirror
MARCH="$1"

if [ -z "$MARCH" ]; then
  echo "Missing -march argument"
  exit 1
fi

if [ "$MARCH" = "x86-64-v4" ]; then
  echo "Error: not working"
  exit 1
fi

echo "Building with -march=$MARCH"

workdir=$(mktemp -d)
cd $workdir

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

tce-load -lwi sdl2-dev git compiletc cmake curl-dev tce-load fontconfig-dev freetype-dev Xorg-7.7-3d-dev liblzma-dev opus-dev mksquashfs-tools sstrip submitqc
export LDFLAGS="-Wl,-O2,--as-needed,--sort-common -flto -fuse-linker-plugin"
export CFLAGS="-fopt-info-vec-optimized -fmerge-all-constants -fno-semantic-interposition -ftree-vectorize -fipa-pta -funroll-loops -floop-nest-optimize -Ofast -march=$MARCH -flto"
export CXXFLAGS="-fopt-info-vec-optimized -fmerge-all-constants -fno-semantic-interposition -ftree-vectorize -fipa-pta -funroll-loops -floop-nest-optimize -Ofast -march=$MARCH -flto"

git clone --recursive https://github.com/OpenTTD/OpenTTD
cd OpenTTD

cmake -DCMAKE_BUILD_TYPE=Release -B build .
cd build
make -j4
make install DESTDIR=/tmp/openttd

sstrip -z /tmp/openttd/usr/local/games/openttd
strip -s /tmp/openttd/usr/local/games/openttd
mkdir -p /tmp/openttd/usr/local/bin
rm -rf /tmp/openttd/usr/local/games
mv /tmp/openttd/usr/local/games/openttd /tmp/openttd/usr/local/bin
mksquashfs /tmp/openttd openttd.tcz

sudo submitqc --nonet --blocksize=65536 openttd.tcz
mv -f openttd.tcz /output/
