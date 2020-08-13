# Kiosk-raspberry documentation
This page contains most basic information about Kiosk-raspberry setup


### Prerequisites

Before executing this script following steps must be executed:

1. Install Raspbian lite with [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/)
2. Bootup and login with default credentials (pi/raspberry). At this screen you can enable SSH server in case it's needed
3. Connect to wifi (`sudo raspi-config`)
4. Execute this script `bash <(curl -sL https://kiosk-rpi-files.s3.eu-central-1.amazonaws.com/prepare-kiosk.sh)`. After script is completed the RPi will reboot and start with kiosk client
5. In case you want to exit kiosk mode: either connect keyboard and enter `ctrl`, `alt` and `backspace` keys combination or connect via SSH

### Generate .img from SD card

In order to reproduce multiple identical Kiosk devices you can create an `.img` backup file, and use it to flash the device.  

1. Attach the source SD card that you want to clone
2. List the local drives mounted on your computer:
    ```bash
    diskutil list
    ```
3. Create the gzipped `img` file:
    ```bash
    sudo dd if=/dev/disk5 bs=1m | gzip > ~/workspace/kiosk-v0.0.5.gz
    ```


### Known Issues

  * **none**
