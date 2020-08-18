#!/usr/bin/env bash
 
# Install dependancies
sudo apt-get install -y git ansible

# Run preparation playbook
sudo ansible-pull --url https://github.com/kihosk/kiosk-os prepare.yml

# Shutdown
sudo shutdown -h now
