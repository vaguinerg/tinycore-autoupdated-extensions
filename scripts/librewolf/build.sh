echo http://distro.ibiblio.org/tinycorelinux/ > /opt/tcemirror
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

tce-load -lwi gnupg libvpx113-dev gtk3-dev nspr-dev rust cbindgen node nasm nss-dev libevent-dev python3.9-pip python3.9-setuptools patchelf freetype-dev fontconfig-dev libXext-dev libxshmfence-dev bash libva22-dev gettext-dev git libvulkan-dev ffmpeg7-dev openal-dev libpulseaudio pulseaudio-dev alsa-dev autoconf perl5 Xorg-7.7-3d-dev submitqc pulseaudio-dev unixODBC-dev bash compiletc libvulkan-dev gnutls38-dev alsa-dev krb5-dev openssl-dev libpcap-dev sdl2-dev opencl-headers pcsc-lite-dev libusb-dev sane-dev libgphoto2-dev gstreamer-dev gst-plugins-base-dev sstrip squashfs-tools binutils coreutils python3.9 python3.9-pip ffmpeg7-dev clang weston-dev
sudo ln -s /usr/local/lib/gcc/ /usr/lib/
# required for staging autoconf, tools/make_requests, wich rebuilds protocols.def, changed by some patches including eventd, needs to be rebuild, and perl link is hardcoded to /usr/bin
sudo cp /usr/local/bin/perl /usr/bin/perl
workdir=$(mktemp -d)
cd $workdir

git clone --recursive https://gitlab.com/librewolf-community/browser/source.git librewolf-source
cd librewolf-source
make dir
make bootstrap
make build
make package
