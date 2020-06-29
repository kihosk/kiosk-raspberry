#!/usr/bin/env bash

# NTP is needed because sometimes after installing new OS RPi - device time is not correct 
sudo apt-get install -y ntp

sudo apt-get update
sudo apt-get install -y --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium fbi ufw unattended-upgrades fail2ban hostapd dnsmasq

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

# splashscreen
sudo sh -c "echo '
[Unit]
Description=Splash screen
DefaultDependencies=no
After=local-fs.target

[Service]
ExecStart=/usr/bin/fbi -d /dev/fb0 --noverbose -a /home/pi/splashscreen.jpg
StandardInput=tty
StandardOutput=tty

[Install]
WantedBy=sysinit.target
'> /etc/systemd/system/splashscreen.service"

sudo sh -c "echo '
disable_splash=1
'>> /boot/config.txt"

sudo sh -c " echo '
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,codename=${distro_codename},label=Debian-Security";
};
Unattended-Upgrade::Package-Blacklist {
};
'> /etc/apt/apt.conf.d/50unattended-upgrades"

# Appending to the last line without new line using `sed`
sudo sed -i -e '${s/$/ logo.nologo consoleblank=0 loglevel=1 quiet/}' /boot/cmdline.txt
wget https://kiosk-rpi-files.s3.eu-central-1.amazonaws.com/splashscreen.jpg
sudo systemctl enable splashscreen  # TODO requires user input (for 'y' char)

#enabling firewall
sudo ufw enable

# fail2ban config
sudo sh -c "echo '
[ssh]
 
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
bantime = 900
banaction = iptables-allports
findtime = 900
maxretry = 3
'> /etc/fail2ban/jail.local"

# unsetting all wifi creds
sudo sh -c "echo '
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
' > /etc/wpa_supplicant/wpa_supplicant.conf"

# Removing bash history
rm .bash_history

sudo reboot