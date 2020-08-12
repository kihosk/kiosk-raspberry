#!/usr/bin/env bash

read -r -p "Are you deploying development environment? [y/N] " choice
choice=${choice,,}    # tolower

PROD_BUILD=1
PURGE_WIFI_CREDS=0
if [[ "$choice" =~ ^(y)$ ]]
then
    PROD_BUILD=0
    read -r -p "Leave existing wifi credentials? [y/N] " wifi_choice
    wifi_choice=${wifi_choice,,}    # tolower
    if [[ "$wifi_choice" =~ ^(yes|y)$ ]]
    then
        PURGE_WIFI_CREDS=1
    fi
else
    PROD_BUILD=1
fi

echo "Build configuration: prod build - ${PROD_BUILD}"

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
disable_overscan=1

#Enabling 4k60Hz for TVs
hdmi_enable_4kp60=1
gpu_mem=128
gpu_mem_256=128
gpu_mem_512=196
gpu_mem_1024=384

hdmi_force_hotplug=1
hdmi_ignore_edid=0xa5000080
hdmi_group=1
#Enabling 1080p mode
hdmi_mode=16

# Increasing signal to HDMI
config_hdmi_boost=4
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
sudo systemctl enable splashscreen

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

if [ $PROD_BUILD = 1 ]; then
    # enabling firewall
    yes | sudo ufw enable
    # TODO assure that ssh is disabled, etc
    
    # preparing first-launch script for generating random password
    echo -e '#!/bin/bash
NEWPW="$(openssl rand -base64 32 | tr -d '\''EOF'\'')"
passwd pi <<EOF
raspberry
$NEWPW
$NEWPW

# Removing script itself after run
sudo rm $0
'> first-launch
    sudo mv first-launch /usr/local/bin/
    sudo chmod +x /usr/local/bin/first-launch

    # Configuring to launch this during the boot
    echo -e '#!/bin/bash
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will exit 0 on success or any other
# value on error
first-launch
exit 0
'> rc.local
    sudo mv rc.local /etc/
fi

if [ $PURGE_WIFI_CREDS = 0 ]; then
    # unsetting all wifi creds
    sudo sh -c "echo '
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    ' > /etc/wpa_supplicant/wpa_supplicant.conf"
fi

# ensure WiFi radio is not blocked (stackoverflow suggests unblocking all RFs)
sudo rfkill unblock all

# deleting machine-id so that it would be re-generated during next boot (so that all new RPis would have different machine-ids)
sudo rm /etc/machine-id
sudo touch /etc/machine-id

# Removing bash history and unsetting current session
rm .bash_history
history -c

# Gracefully shutting down the RPi
sudo shutdown -h now
