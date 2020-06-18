#!/usr/bin/env bash

# NTP is needed because sometimes after installing new OS RPi - device time is not correct 
sudo apt-get install -y ntp

sudo apt-get update
sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox vim chromium

# openbox configuration
sudo sh -c "echo '
# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

# Allow quitting the X server with CTRL-ATL-Backspace
setxkbmap -option terminate:ctrl_alt_bksp
/home/pi/kiosk-app.AppImage
'>> /etc/xdg/openbox/autostart"

# Downloading latest alpha release
latestAlphaPath=$(curl -s https://kiosk-app-files.s3.eu-central-1.amazonaws.com/alpha-linux-arm.yml | sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' | grep path | sed 's/[^"]*"\([^"]*\)".*/\1/')
wget "https://kiosk-app-files.s3.eu-central-1.amazonaws.com/$latestAlphaPath"
mv $latestAlphaPath kiosk-app.AppImage
chmod +x kiosk-app.AppImage

# Configuring to start x11 on boot
echo "[[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && startx -- -nocursor" >> .bashrc

# automatic login for pi user
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo sh -c "echo '[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${USER} --noclear %I 38400 linux
'>/etc/systemd/system/getty@tty1.service.d/autorun.conf"

echo "changed"
sudo reboot