#!/bin/bash

install_apt_packages() {
  echo "Updating package lists..."
  sudo apt update -qq || {
    echo "Failed to update package lists. Exiting."
    exit 1
  }

  echo "Installing required packages..."
  sudo apt install -y -qq \
    ca-certificates \
    neovim \
    bind9-dnsutils \
    curl \
    tmux \
    fish \
    git || {
    echo "Package installation failed. Exiting."
    exit 1
  }
}

add_3p_repos() {
  echo "Adding third party repositories..."
  sudo install -m 0755 -d /etc/apt/keyrings

  # Docker
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Using debian repo for 64-bit, bookworm as trixie is not yet supported
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    bookworm stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  # Mise
  curl -fsSL https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.pub >/dev/null

  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.pub arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" |
    sudo tee /etc/apt/sources.list.d/mise.list >/dev/null

  sudo apt update -qq || {
    echo "Failed to update package lists after adding third party repos. Exiting."
    exit 1
  }
}

install_3p_packages() {
  echo "Installing third party packages..."
  sudo apt install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    mise || {
    echo "Failed to install third party packages. Exiting."
    exit 1
  }

  echo "Adding user to docker group..."
  sudo usermod -aG docker "$USER" || {
    echo "Failed to add user to docker group. Exiting."
    exit 1
  }
}

setup_mise_environments() {
  echo "Setting up mise environments..."
  mise use -g node rust ruby || {
    echo "Failed to install environments with mise. Exiting."
    exit 1
  }
  echo "  ✓ Node, Rust and Ruby configured"
}

disable_wifi_power_management() {
  echo "  Disabling WiFi power saving..."
  sudo iw dev wlan0 set power_save off 2>/dev/null || true

  sudo mkdir -p /etc/NetworkManager/conf.d
  sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null <<EOF
[connection]
wifi.powersave = 2
EOF
  echo "  ✓ WiFi power management disabled"
}

setup_wifi_workaround() {
  echo "  Setting up WiFi driver workaround service..."
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  sudo cp "$SCRIPT_DIR/configs/wlan0-promisc-toggle.service" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable wlan0-promisc-toggle.service

  echo "  ✓ WiFi workaround service installed and enabled"
}

configure_ipv6() {
  sudo tee /etc/sysctl.d/99-enable-ipv6.conf >/dev/null <<EOF
# Enable IPv6 on all interfaces
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.eth0.disable_ipv6 = 0
net.ipv6.conf.wlan0.disable_ipv6 = 0
EOF

  sudo sysctl -p /etc/sysctl.d/99-enable-ipv6.conf >/dev/null

  # Verify IPv6 is working
  if ip -6 addr show | grep -q "inet6"; then
    echo "  ✓ IPv6 addresses detected"
  else
    echo "  Warning: No IPv6 addresses found (may need reboot or router doesn't support IPv6)"
  fi
}

setup_configs() {
  echo "Setting up configs..."
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  mkdir -p ~/.config/fish
  cp "$SCRIPT_DIR/configs/config.fish" ~/.config/fish/config.fish
  sudo chsh -s "$(command -v fish)" "$USER"
  echo "  ✓ Fish configured (will take effect on next login)"

  cp "$SCRIPT_DIR/configs/tmux.conf" ~/.tmux.conf
  echo "  ✓ Tmux configured"
}

fyi_post_install() {
  echo "(optional) Log out and back in for docker group changes to take effect."
}

main() {
  install_apt_packages
  add_3p_repos
  install_3p_packages
  setup_mise_environments
  disable_wifi_power_management
  setup_wifi_workaround
  configure_ipv6
  setup_configs
  fyi_post_install

  echo "Script completed successfully!"
}

main
