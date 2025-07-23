echo http://mirror.math.princeton.edu/pub/tinycorelinux/ > /opt/tcemirror
export MARCH="$1"

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
workdir=$(mktemp -d)
cp /scripts/mozconfig $workdir
cd $workdir

export LDFLAGS="-Wl,-O2,--as-needed-flto -fuse-linker-plugin"

tce-load -lwi python compiletc Xorg-7.7-3d-dev gtk3-dev yasm python-dev coreutils binutils zip perl5 alsa-dev ffmpeg7-dev clang xz tar \
 squashfs-tools node sstrip gstreamer cairo-dev cairomm-dev pixman-dev submitqc
tce-load -lwi hunspell-dev readline-dev
sudo rm -rf /usr/bin/xz
sudo rm -rf /bin/tar
sudo cp /usr/local/bin/tar /bin/tar
sudo cp /usr/local/bin/xz /bin/xz

#Fix broken clang
sudo ln -s /usr/local/lib/gcc/ /usr/lib/

wget -O- --no-check-certificate https://repo.palemoon.org/MoonchildProductions/Pale-Moon/archive/33.8.0_Release-r2.tar.gz | tar -xz
wget -O- --no-check-certificate https://repo.palemoon.org/MoonchildProductions/UXP/archive/RB_20250703.tar.gz | tar -xz --strip-components=1 -C pale-moon/platform

cp mozconfig pale-moon/.mozconfig
cd pale-moon
./mach build
./mach package
wget http://mirror.math.princeton.edu/pub/tinycorelinux/16.x/x86_64/tcz/palemoon.tcz
unsquashfs palemoon.tcz
rm -rf palemoon.tcz
cd squashfs-root/usr/local/
rm -rf palemoon/
tar xvf ../../../obj-x86_64-pc-linux-gnu/dist/*.tar.xz
sstrip -z palemoon/*
cd ../../../
mksquashfs squashfs-root palemoon.tcz
sudo submitqc --nonet --blocksize=65536 palemoon.tcz
mv -f palemoon.tcz /output
