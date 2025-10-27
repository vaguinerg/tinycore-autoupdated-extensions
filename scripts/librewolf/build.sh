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
sudo ln -s /lib /lib64

tce-load -lwi sstrip patchelf findutils xz pixman-dev libvpx113-dev libjpeg-turbo-dev libpng-dev libwebp1-dev boost-1.84-dev libaom-dev libdrm-dev libEGL-dev libffi-dev gnupg libvpx113-dev gtk3-dev nspr-dev rust cbindgen node nasm nss-dev libevent-dev python3.9-pip python3.9-setuptools patchelf freetype-dev fontconfig-dev libXext-dev libxshmfence-dev bash libva22-dev gettext-dev git libvulkan-dev ffmpeg7-dev openal-dev libpulseaudio pulseaudio-dev alsa-dev autoconf perl5 Xorg-7.7-3d-dev submitqc pulseaudio-dev unixODBC-dev bash compiletc libvulkan-dev gnutls38-dev alsa-dev krb5-dev openssl-dev libpcap-dev sdl2-dev opencl-headers pcsc-lite-dev libusb-dev sane-dev libgphoto2-dev gstreamer-dev gst-plugins-base-dev sstrip squashfs-tools binutils coreutils python3.9 python3.9-pip ffmpeg7-dev clang
tce-load -lwi tar p7zip ccache
export CCACHE_DIR=/output/ccache
sudo rm -rf /bin/tar
sudo cp /usr/local/bin/tar /bin
sudo rm -rf /usr/bin/xz
sudo cp /usr/local/bin/xz /usr/bin

wget https://github.com/mozilla/sccache/releases/download/v0.8.2/sccache-v0.8.2-x86_64-unknown-linux-musl.tar.gz
tar xzf sccache-v0.8.2-x86_64-unknown-linux-musl.tar.gz
sudo cp sccache-v0.8.2-x86_64-unknown-linux-musl/sccache /usr/local/bin/
sudo chmod +x /usr/local/bin/sccache

sudo ln -s /usr/local/lib/gcc/ /usr/lib/
sudo cp /usr/local/bin/perl /usr/bin/perl
workdir=$(mktemp -d)
cd $workdir

sudo python3.9 -m ensurepip
python3.9 -m pip install setuptools
python3.9 -m pip install easy_install
python3.9 -m pip install pyyaml==6.0.2

git clone --recursive https://gitlab.com/librewolf-community/browser/source.git librewolf-source
cd librewolf-source
make dir
cd librewolf*

export RUSTC_WRAPPER=sccache
export CC="sccache gcc"
export CXX="sccache g++"

sed -i 's/^ac_add_options --enable-bootstrap/#&/' mozconfig
sed -i 's/^ac_add_options --enable-optimize/#&/' mozconfig

cat << 'EOF' >> mozconfig

ac_add_options --enable-optimize="-O3 -march=$MARCH"
ac_add_options --disable-debug-symbols
ac_add_options --disable-elf-hack
ac_add_options --enable-lto=full

#ac_add_options --enable-profile-generate=cross
#ac_add_options --enable-profile-use=cross
#ac_add_options --with-pgo-profile-path="${PWD}/merged.profdata"
#ac_add_options --with-pgo-jarlog="${PWD}/jarlog"

ac_add_options --prefix=/usr/local

ac_add_options --without-wasm-sandboxed-libraries
ac_add_options --disable-bootstrap
ac_add_options --disable-dbus
ac_add_options --disable-necko-wifi

ac_add_options --enable-ffmpeg
ac_add_options --enable-alsa

ac_add_options --with-system-ffi
ac_add_options --with-system-gbm
ac_add_options --with-system-libdrm
ac_add_options --with-system-zlib
ac_add_options --with-system-nspr
ac_add_options --with-system-libevent
ac_add_options --with-system-pixman

ac_add_options --with-system-webp
ac_add_options --with-system-jpeg
ac_add_options --with-system-libvpx

EOF

#ac_add_options --with-system-av1 > Wont work with aom? Dav1 required version is 1.2.1
#ac_add_options --with-system-nss: Requested 'nss >= 3.105' but version of NSS is 3.104.0
#ac_add_options --with-system-png: Requested 'libpng >= 1.6.45' but version of libpng is 1.6.40

cd ..

#make bootstrap
make build
make package

find . -iname *.zip
find . -iname librewolf

mksquashfs ./obj-x86_64-pc-linux-gnu librewolf.tcz
mv -f librewolf.tcz /output/

find /output/ccache
ccache -s
