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

tce-load -lwi python compiletc Xorg-7.7-3d-dev gtk3-dev yasm python-dev coreutils binutils zip perl5 alsa-dev ffmpeg7-dev clang xz tar \
 squashfs-tools node sstrip gstreamer cairo-dev cairomm-dev pixman-dev submitqc
tce-load -lwi hunspell-dev readline-dev
sudo rm -rf /usr/bin/xz
sudo rm -rf /bin/tar
sudo cp /usr/local/bin/tar /bin/tar
sudo cp /usr/local/bin/xz /bin/xz

#Fix broken clang
sudo ln -s /usr/local/lib/gcc/ /usr/lib/

wget -O- --no-check-certificate https://repo.palemoon.org/Basilisk-Dev/Basilisk/archive/v2025.07.04.tar.gz | tar -xz
wget -O- --no-check-certificate https://repo.palemoon.org/MoonchildProductions/UXP/archive/05bae9bb7231eb6fd851802d097400542bba50a1.tar.gz | tar -xz --strip-components=1 -C basilisk/platform


cp mozconfig basilisk/.mozconfig
cd basilisk
./mach build
./mach package
