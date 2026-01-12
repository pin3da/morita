#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGER_URL="https://downloads.raspberrypi.org/imager/imager_latest_amd64.AppImage"
IMAGER_FILE="${SCRIPT_DIR}/rpi-imager.AppImage"

check_dependencies() {
  sudo apt install -y pkexec wget libfuse3-4
}

download_imager() {
  if [ -f "$IMAGER_FILE" ]; then
    read -p "AppImage exists. Re-download? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return 0
    fi
    rm "$IMAGER_FILE"
  fi
  wget -O "$IMAGER_FILE" "$IMAGER_URL"
}

main() {
  check_dependencies
  download_imager
  chmod +x "$IMAGER_FILE"
  echo "Done. Run: pkexec $IMAGER_FILE"
}

main "$@"
