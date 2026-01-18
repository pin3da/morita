#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CADDY_DIR="$PROJECT_ROOT/caddy"

check_prerequisites() {
  echo "Checking prerequisites..."

  # Check if Docker is installed
  if ! command -v docker &>/dev/null; then
    echo "  ✗ Docker is not installed"
    echo "  Please install Docker first (see main README or run bootstrap.sh)"
    exit 1
  fi
  echo "  ✓ Docker is installed"

  # Check if Docker Compose is available
  if ! docker compose version &>/dev/null; then
    echo "  ✗ Docker Compose is not available"
    echo "  Please install Docker Compose plugin"
    exit 1
  fi
  echo "  ✓ Docker Compose is available"

  # Check if Docker daemon is running
  if ! docker ps &>/dev/null; then
    echo "  ✗ Docker daemon is not running"
    echo "  Please start Docker: sudo systemctl start docker"
    exit 1
  fi
  echo "  ✓ Docker daemon is running"

  # Check if user is in docker group
  if ! groups | grep -q docker; then
    echo "  ⚠ Warning: User is not in docker group"
    echo "  You may need to use sudo or add user to docker group:"
    echo "  sudo usermod -aG docker $USER"
    echo "  Then log out and back in"
    echo ""
  fi
}

setup_environment() {
  echo "Setting up environment configuration..."

  cd "$CADDY_DIR" || exit 1

  # Check if .env already exists
  if [ -f ".env" ]; then
    echo "  ⚠ .env file already exists"
    read -p "  Do you want to reconfigure it? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "  ✓ Keeping existing .env file"
      return 0
    fi
  fi

  # Copy template
  cp .env.example .env
  echo "  ✓ Created .env file from template"
  echo ""

  # Prompt for domain
  echo "==================================================================="
  echo "IMPORTANT: You need to configure your environment"
  echo "==================================================================="
  echo ""
  read -p "Enter your domain name (e.g., example.com): " DOMAIN
  read -p "Enter your email for Let's Encrypt notifications: " EMAIL
  echo ""

  # Update .env file
  sed -i "s/DOMAIN=.*/DOMAIN=$DOMAIN/" .env
  sed -i "s/EMAIL=.*/EMAIL=$EMAIL/" .env

  echo "  ✓ Environment configured"
  echo ""
}

display_next_steps() {
  echo "For detailed documentation, see: $CADDY_DIR/README.md"
}

prompt_start_caddy() {
  read -p "Do you want to start Caddy now? (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting Caddy..."
    cd "$CADDY_DIR" || exit 1

    docker compose up -d

    echo ""
    echo "  ✓ Caddy is running"
    echo ""
    echo "View logs with: cd $CADDY_DIR && docker compose logs -f caddy"
    echo ""
  else
    echo ""
    echo "To start Caddy later, run:"
    echo "  cd $CADDY_DIR && docker compose up -d"
    echo ""
  fi
}

main() {
  echo "==================================================================="
  echo "Caddy Reverse Proxy Setup"
  echo "==================================================================="
  echo ""

  check_prerequisites
  setup_environment
  display_next_steps
  prompt_start_caddy

  echo "Setup complete!"
}

main "$@"
