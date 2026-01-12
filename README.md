# Raspberry Pi 5 Setup

Documentation for setting up a Raspberry Pi 5 to boot from USB/HDD without SD card or monitor.

## Hardware Requirements

- **Board**: Raspberry Pi 5
- **Storage**: USB HDD/SSD (any size, formatted during setup)
- **Power Supply**: Official Raspberry Pi 5 Power Supply (5V 5A / 25W)
  - *Critical*: USB boot requires adequate power supply
- **Network**: Ethernet cable or WiFi credentials

## Prerequisites

- A computer running Debian/Linux for initial preparation

## Initial Setup (One-Time)

### 1. Install Raspberry Pi Imager on Debian

```bash
./download-imager.sh
```


Also needs to fix access to the X server in order to run the imager with sudo:

```bash
xhost +si:localuser:root
```

### 2. Prepare the HDD

1. Connect your HDD to your Debian machine via USB

2. Launch Raspberry Pi Imager:

```bash
./rpi-imager.AppImage
```

3. Configure the image:
   - **Choose Device**: Raspberry Pi 5
   - **Choose OS**: Raspberry Pi OS (other) → Raspberry Pi OS Lite (64-bit)
   - **Choose Storage**: Select your HDD
   
4. **Open Advanced Options** (gear icon or Ctrl+Shift+X):
   - ✓ Enable SSH
   - Set username and password
   - Configure WiFi (if not using Ethernet)
   - Set hostname (e.g., `morita`)
   - Set locale settings (timezone, keyboard layout)

5. Write the image to the HDD

### 3. Boot the Raspberry Pi

1. Remove the HDD from your computer
2. Connect HDD to one of the **blue USB 3.0 ports** on the Pi 5
3. Connect Ethernet cable (optional if WiFi configured)
4. Plug in the official power supply
5. Wait 1-2 minutes for first boot

### 4. Connect via SSH

From your Debian machine:

```bash
# You can find all the servers that respond to mDNS with:
avahi-browse -a

# Then connect using hostname (via mDNS)
ssh username@morita.local


# Or if you know the IP
ssh username@192.168.1.xxx
```

### 5. Bootstrap the Raspberry Pi

Copy and run the bootstrap script to install git and docker:

```bash
scp bootstrap.sh username@morita.local:~/
ssh username@morita.local
./bootstrap.sh
```

Log out and back in after running for docker group changes to take effect.

### TODOs

- [ ] Configure keys in the raspberry to clone repos
- [ ] Write a bootstrap script
- [ ] Use a dedicated ip?
