# Raspberry Pi 5 Setup

Headless Raspberry Pi 5 setup booting from USB HDD (no SD card or monitor needed).

## Hardware

- Raspberry Pi 5 with official power supply (5V 5A / 25W required for USB boot)
- USB HDD/SSD
- Ethernet or WiFi

## Setup

### 1. Prepare the HDD

```bash
# Allow root to use X display
xhost +si:localuser:root

# Download and run imager
./download-imager.sh
./rpi-imager.AppImage
```

In the imager:
- **Device**: Raspberry Pi 5
- **OS**: Raspberry Pi OS Lite (64-bit)
- **Storage**: Your HDD
- **Advanced Options** (gear icon): Enable SSH, set username/password, configure WiFi, set hostname

### 2. Boot the Pi

Connect HDD to a **blue USB 3.0 port**, plug in power, wait 1-2 minutes.

### 3. Connect via SSH

```bash
# Find devices via mDNS
avahi-browse -a

# Connect
ssh <username>@<hostname>.local
```

### 4. Bootstrap

```bash
scp -r configs/ bootstrap.sh <username>@<hostname>.local:~/bootstrap/
ssh <username>@<hostname>.local
cd bootstrap && ./bootstrap.sh
```

Log out and back in for group changes to take effect.

### 5. Set Up Caddy Reverse Proxy (Optional)

For HTTPS access to self-hosted services with automatic Let's Encrypt certificates:

```bash
./setup-caddy.sh
```

See [caddy/README.md](caddy/README.md) for detailed configuration, DDNS setup, and adding services.

## Troubleshooting

### WiFi Connectivity Issue (brcmfmac driver bug)

**Symptoms:** Pi unreachable from one specific computer but works from others. ARP works, ping fails.

```bash
# Diagnosis - arping works but ping fails
sudo arping -I <interface> <ip_raspberry>  # works
ping <ip_raspberry>                        # fails
```

**Quick fix (on the Pi):**
```bash
sudo ip link set wlan0 promisc on && sleep 1 && sudo ip link set wlan0 promisc off
```

**Root cause:** The Pi 5's Broadcom WiFi driver (brcmfmac) can get into a bad state where it stops responding to unicast packets from specific hosts.

**Permanent solution:** The bootstrap script installs a systemd service that toggles promiscuous mode on boot, which clears the driver state. Alternatively, use Ethernet for more reliable connectivity.

**Check service status:**
```bash
# View service status
sudo systemctl status wlan0-promisc-toggle.service

# Check if enabled at boot
systemctl is-enabled wlan0-promisc-toggle.service

# View logs
journalctl -u wlan0-promisc-toggle.service

# Manually trigger (for testing)
sudo systemctl start wlan0-promisc-toggle.service
```
