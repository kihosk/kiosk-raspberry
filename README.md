# Kiosk-raspberry documentation

This page contains most basic information about Kiosk-raspberry setup

### Prerequisites

Before executing this script following steps must be executed:

1. Install ansible

```bash
brew install ansible
```

2. Install sshpass

```bash
brew install hudochenkov/sshpass/sshpass
```

2. Install Raspberry Pi Imager
3. Clone the `kiosk-electron` repository
4. Newer versions of Docker desktop come with an incompatible [file sharing protocol](https://docs.docker.com/docker-for-mac/release-notes/#docker-desktop-community-2400). To switch back, go to Docker > Preferences > General and disable gRPC-FUSE. 

### Create golden SD card (macOS)

1. Use [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/) to flash an SD card with `Raspbian OS Lite`
2. Bootup the raspberry pi and login with default credentials (pi/raspberry).
3. Connect the raspberry to wifi (`sudo raspi-config`)
4. Enable ssh for the raspberry (`sudo raspi-config`)
5. Find the raspberry's local ip address with `ifconfig`
   _We'll assume it's `192.168.0.50` for this example_
6. On your local machine, from the `kiosk-electron/ansible` directory run the command:
   ```
   ansible-playbook prepare.yml -i 192.168.0.50, -e "{target: 192.168.0.50}" -u pi --ask-pass
   ```
   _Note the ip address of the target raspberry_

*Note: While the kiosk is running, in case you want to exit kiosk mode: either connect keyboard and enter `ctrl`, `alt` and `backspace` keys combination or connect via SSH*

### Generate .img from golden SD card (macOS)

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

### Compress image

You can use xz for compressing the shrinked image, reducing the size from ~3.5GB down to ~990MB

```bash
xz -k out/kiosk-0.0.13-shrinked.img
```