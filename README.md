# Kiosk-raspberry documentation

This page contains most basic information about Kiosk-raspberry setup

### Prerequisites

Before executing this script following steps must be executed:

1. Install Raspbian lite with [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/)
2. Bootup and login with default credentials (pi/raspberry). At this screen you can enable SSH server in case it's needed
3. Connect to wifi (`sudo raspi-config`)
4. Execute this script `bash <(curl -sL https://kiosk-rpi-files.s3.eu-central-1.amazonaws.com/prepare-kiosk.sh)`. After script is completed the RPi will reboot and start with kiosk client
5. In case you want to exit kiosk mode: either connect keyboard and enter `ctrl`, `alt` and `backspace` keys combination or connect via SSH

### Generate .img from SD card (macOS)

Prerequisite:

- docker
- macos

In order to reproduce multiple identical Kiosk devices you can create an `.img` backup file, and use it to flash the device.

1. Attach the source SD card that you want to clone
2. List the local drives mounted on your computer:

   ```bash
   diskutil list
   ```

3. Create the `img` file:

   ```bash
   ./sd_card_to_image.sh version=0.0.15 disk=2
   ```

   This will create a file named `kiosk-0.0.15-shrinked.img` in a directory named `out`

### Write img to SD card (macOS)

Ensure you have the image file in the location: `/kiosk-raspberry/out/kiosk-0.0.15-shrinked.img`. Not the .xz file, but the decompressed .img file.

Run the following:

```bash
./image_to_sd_card.sh version=0.0.15 disk=2
```

### Known Issues

- **none**
