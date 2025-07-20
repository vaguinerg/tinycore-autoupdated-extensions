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
tce-load -lwi autoconf perl5 Xorg-7.7-3d-dev submitqc pulseaudio-dev unixODBC-dev bash compiletc libvulkan-dev gnutls38-dev alsa-dev krb5-dev openssl-dev libpcap-dev sdl2-dev opencl-headers pcsc-lite-dev libusb-dev sane-dev libgphoto2-dev gstreamer-dev gst-plugins-base-dev weston-dev sstrip squashfs-tools binutils coreutils python3.9 python3.9-pip ffmpeg7-dev clang
sudo ln -s /usr/local/lib/gcc/ /usr/lib/
# required for staging autoconf, tools/make_requests, wich rebuilds protocols.def, changed by some patches including eventd, needs to be rebuild, and perl link is hardcoded to /usr/bin
sudo cp /usr/local/bin/perl /usr/bin/perl
workdir=$(mktemp -d)
cd $workdir

#Eventfd disabled from version 10.11, to prepare for NTSYNC, which is only available in kernel 6.14, while tinycore is still in 6.12.
wine=10.10
staging=c37f9f50912bd801e217ba81d2512feb7386f0d1

#get wine
wget -O- --no-check-certificate https://dl.winehq.org/wine/source/10.x/wine-$wine.tar.xz | tar -xJ

#get staging
wget --no-check-certificate -O- https://codeload.github.com/wine-staging/wine-staging/zip/$staging | busybox unzip -qq -
cd wine-staging-$staging/
chmod u+x ./patches/gitapply.sh
python3.9 ./staging/patchinstall.py DESTDIR=../wine-$wine/ --all -W server-Stored_ACLs

cd ../wine-$wine/

#fix ca-certificates & ca-bundle location
sed -i 's#/etc/ssl/certs/ca-certificates.crt#/usr/local/etc/ssl/certs/ca-certificates.crt#' ./dlls/crypt32/unixlib.c
sed -i 's#/usr/share/ca-certificates/ca-bundle.crt#/usr/local/etc/ssl/ca-bundle.crt#' ./dlls/crypt32/unixlib.c

#get mingw for WoW64 support
wget -O- --no-check-certificate https://github.com/mstorsjo/llvm-mingw/releases/download/20250709/llvm-mingw-20250709-ucrt-ubuntu-22.04-x86_64.tar.xz | tar xJ
export PATH=$PATH:./llvm-mingw-20250709-ucrt-ubuntu-22.04-x86_64/bin/

sudo ln -s /lib /lib64

#compile
export CFLAGS="-fopt-info-vec-optimized -fmerge-all-constants -fno-semantic-interposition -ftree-vectorize -fipa-pta -funroll-loops -floop-nest-optimize -O3 -march=$MARCH -mtune=$MARCH"
export CXXFLAGS="-fopt-info-vec-optimized -fmerge-all-constants -fno-semantic-interposition -ftree-vectorize -fipa-pta -funroll-loops -floop-nest-optimize -O3 -march=$MARCH -mtune=$MARCH"
export LDFLAGS="-Wl,-O2,--as-needed"

./configure --libdir=/usr/local/lib --prefix=/usr/local --localstatedir=/var --without-dbus --enable-archs=i386,x86_64 --disable-win16 --disable-tests
find . -name Makefile -type f -exec sed -i 's/-g -O2/-O3 -march=$MARCH -mtune=$MARCH -Rpass=loop-vectorize/g' {} \;

make -j8
make install DESTDIR=/tmp/wine
find /tmp/wine/ -exec strip -s {} \;
find /tmp/wine/ -exec x86_64-w64-mingw32-strip -s {} \;
find /tmp/wine/ -exec i686-w64-mingw32-strip -s {} \;
#/\ not needed? 64bit strip seems to be stripping 32bits files

find /tmp/wine/ -iname *.a -delete
mksquashfs /tmp/wine/ wine-latest.tcz -e usr/local/bin/winegcc -e usr/local/bin/wineg++ -e usr/local/bin/winecpp -e usr/local/bin/function_grep.pl -e usr/local/include -e usr/local/share/man
sudo submitqc --nonet --blocksize=65536 wine-latest.tcz
mv -f wine-latest.tcz /output/wine.tcz
