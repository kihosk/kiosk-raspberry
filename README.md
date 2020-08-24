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

In order to reproduce multiple identical Kiosk devices you can create an `.img` backup file, and use it to flash the device.  

1. Attach the source SD card that you want to clone
2. List the local drives mounted on your computer:
    ```bash
    diskutil list
    ```

3. Create the zipped `img` file:
    ```bash
    # full size
    sudo dd if=/dev/rdisk5 of=kiosk-v0.0.7.img bs=4m

    # gzip
    sudo dd if=/dev/rdisk5 bs=1m | gzip > kiosk-v0.0.7.img.gz
    
    # xz
    sudo dd if=/dev/rdisk5 bs=1m | xz > kiosk-v0.0.7.img.xz
    ```

### Shrink image 
You can use the script below to take your regular `.img` file and shrink it. 

```bash
docker run --rm --privileged=true -v `pwd`:/workdir turee/pishrink-docker pishrink kiosk-v0.0.7.img kiosk-v0.0.7-shrinked.img
```

This technique also has the advantage that you may write the output image to sd cards which don't match in size with the original. 


### Write img to SD card (macOS)

The script below shows you how to write an img file to an sd card using the command line tools

```bash
# First unmount the target disk
diskutil unmountDisk /dev/disk5

# Secondly, flash the disk
sudo dd bs=1m if=kiosk-v0.0.7-shrinked.img of=/dev/rdisk5; sync

# Eject the disk for safety
sudo diskutil eject /dev/rdisk2
```

### Known Issues

  * **none**
