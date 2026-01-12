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
    git || {
    echo "Package installation failed. Exiting."
    exit 1
  }
}

add_docker_repo() {
  echo "Adding docker apt repository..."
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Using debian repo for 64-bit, bookworm as trixie is not yet supported
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    bookworm stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt update -qq || {
    echo "Failed to update package lists after adding docker repo. Exiting."
    exit 1
  }
}

install_docker() {
  echo "Installing docker..."
  sudo apt install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin || {
    echo "Failed to install docker. Exiting."
    exit 1
  }

  echo "Adding user to docker group..."
  sudo usermod -aG docker "$USER" || {
    echo "Failed to add user to docker group. Exiting."
    exit 1
  }
}

fyi_post_install() {
  echo "Log out and back in for docker group changes to take effect."
}

main() {
  install_apt_packages
  add_docker_repo
  install_docker
  fyi_post_install

  echo "Script completed successfully!"
}

main
