# Caddy Reverse Proxy Setup

Automatic HTTPS reverse proxy for self-hosted services using Caddy and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed (see main README)
- Domain name pointing to your public IP
- Ports 80 and 443 forwarded to your Raspberry Pi

## Quick Start

```bash

# 1. Prepare environment variables
cp .env.example .env
# Now edit .env

# 2. Configure DNS records
# Add A records at your DNS provider:
#   @ → your_public_ip
#   * → your_public_ip (wildcard for subdomains, or add each of them explicitly)

# 3. Configure port forwarding on your router
#   80/TCP  → Raspberry Pi IP:80
#   443/TCP → Raspberry Pi IP:443
#   443/UDP → Raspberry Pi IP:443 (optional, for HTTP/3)

# 4. Start Caddy
docker compose up -d

# 5. Check logs
docker compose logs -f caddy

# 6. Verify HTTPS works
# Visit https://yourdomain.com
```

## Dynamic DNS (DDNS)

If your ISP assigns a dynamic IP address, you'll need DDNS. Check if your IP changes:

```bash
curl 'https://api.ipify.org?format=json' # Note the IP, check again later
```

If your registar supports it, you might use ddclient for dynamic DNS configuration.

## Adding Services

Edit `Caddyfile` and add your service:

```caddyfile
myservice.yourdomain.com {
    import logging
    import security_headers
    reverse_proxy container_name:port {
        import proxy_headers
    }
}
```

Reload configuration (no restart needed):

```bash
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Common Commands

```bash
# Start/stop
docker compose up -d
docker compose down

# View logs
docker compose logs -f caddy

# Reload config
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Validate Caddyfile syntax
docker exec caddy caddy validate --config /etc/caddy/Caddyfile

```

## Troubleshooting

**Certificate not issuing:**
- Verify DNS: `dig yourdomain.com +short` (should return your public IP)
- Check ports are accessible from internet
- Check logs: `docker compose logs caddy | grep -i error`

**Service not accessible (502 Bad Gateway):**
- Verify service is running: `docker compose ps`
- Ensure service is on same Docker network as Caddy
- Check container name and port in Caddyfile

**Port already in use:**
- Check what's using port: `sudo lsof -i :80` or `sudo lsof -i :443`
- Stop conflicting service (Apache, nginx, etc.)
