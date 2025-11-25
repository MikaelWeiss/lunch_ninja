# LunchNinja Deployment Guide

This guide walks you through deploying LunchNinja to a self-hosted server.

## Prerequisites

- Linux server (Ubuntu 20.04+ recommended)
- PostgreSQL 14+
- Erlang 26+ and Elixir 1.15+
- Domain name configured with DNS
- SSL certificate (Let's Encrypt recommended)
- Resend account for email delivery

## Environment Variables

Create a `.env` file or set these environment variables on your server:

```bash
# Database
DATABASE_URL=ecto://username:password@localhost/lunch_ninja_prod

# Phoenix
SECRET_KEY_BASE=<generate with: mix phx.gen.secret>
PHX_HOST=lunchninja.org
PORT=4000
PHX_SERVER=true

# Email (Resend)
RESEND_API_KEY=re_...

# Optional
POOL_SIZE=10
```

## Step 1: Server Setup

### Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Erlang and Elixir
sudo apt install -y erlang elixir

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Node.js (for asset compilation)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### Create Database

```bash
sudo -u postgres psql

CREATE DATABASE lunch_ninja_prod;
CREATE USER lunch_ninja WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE lunch_ninja_prod TO lunch_ninja;
\q
```

## Step 2: Build Release

On your development machine or CI/CD:

```bash
# Install dependencies
mix deps.get --only prod

# Compile assets
MIX_ENV=prod mix assets.deploy

# Compile release
MIX_ENV=prod mix release
```

This creates a release at `_build/prod/rel/lunch_ninja/`.

## Step 3: Deploy to Server

### Transfer Release

```bash
# From your local machine
scp -r _build/prod/rel/lunch_ninja user@your-server:/opt/lunch_ninja
```

### Set Up Systemd Service

Create `/etc/systemd/system/lunch_ninja.service`:

```ini
[Unit]
Description=LunchNinja Phoenix Application
After=network.target postgresql.service

[Service]
Type=simple
User=lunch_ninja
Group=lunch_ninja
WorkingDirectory=/opt/lunch_ninja
Environment="PORT=4000"
Environment="PHX_SERVER=true"
Environment="DATABASE_URL=ecto://lunch_ninja:password@localhost/lunch_ninja_prod"
Environment="SECRET_KEY_BASE=your_secret_key_base"
Environment="PHX_HOST=lunchninja.org"
Environment="RESEND_API_KEY=re_your_api_key"
ExecStart=/opt/lunch_ninja/bin/lunch_ninja start
ExecStop=/opt/lunch_ninja/bin/lunch_ninja stop
Restart=on-failure
RestartSec=5
SyslogIdentifier=lunch_ninja

[Install]
WantedBy=multi-user.target
```

### Create Service User

```bash
sudo useradd -r -s /bin/false lunch_ninja
sudo chown -R lunch_ninja:lunch_ninja /opt/lunch_ninja
```

### Start Service

```bash
# Run migrations
sudo -u lunch_ninja /opt/lunch_ninja/bin/lunch_ninja eval "LunchNinja.Release.migrate"

# Enable and start service
sudo systemctl enable lunch_ninja
sudo systemctl start lunch_ninja

# Check status
sudo systemctl status lunch_ninja
```

## Step 4: Configure Nginx Reverse Proxy

Install Nginx:

```bash
sudo apt install -y nginx
```

Create `/etc/nginx/sites-available/lunchninja`:

```nginx
upstream phoenix {
    server 127.0.0.1:4000;
}

server {
    listen 80;
    server_name lunchninja.org www.lunchninja.org;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name lunchninja.org www.lunchninja.org;

    ssl_certificate /etc/letsencrypt/live/lunchninja.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/lunchninja.org/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        proxy_pass http://phoenix;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;

        # WebSocket support
        proxy_read_timeout 86400;
    }

    # Cache static assets
    location ~* ^/assets/ {
        proxy_pass http://phoenix;
        proxy_cache_valid 200 1y;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/lunchninja /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Step 5: SSL Certificate with Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d lunchninja.org -d www.lunchninja.org

# Auto-renewal is configured automatically
sudo certbot renew --dry-run
```

## Step 6: Configure Resend

1. Sign up at https://resend.com
2. Verify your domain (lunchninja.org)
3. Add DNS records as instructed by Resend
4. Create an API key
5. Add the API key to your environment variables

## Step 7: Run Migrations

Create a helper module at `lib/lunch_ninja/release.ex`:

```elixir
defmodule LunchNinja.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :lunch_ninja

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

Then run:

```bash
sudo -u lunch_ninja /opt/lunch_ninja/bin/lunch_ninja eval "LunchNinja.Release.migrate"
```

## Step 8: Health Checks

Test your deployment:

```bash
# Check if app is running
curl http://localhost:4000

# Check HTTPS
curl https://lunchninja.org

# Check logs
sudo journalctl -u lunch_ninja -f
```

## Monitoring & Maintenance

### View Logs

```bash
# Application logs
sudo journalctl -u lunch_ninja -f

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Restart Application

```bash
sudo systemctl restart lunch_ninja
```

### Database Backups

Set up daily backups:

```bash
# Create backup script
sudo nano /usr/local/bin/backup_lunch_ninja.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/lunch_ninja"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
sudo -u postgres pg_dump lunch_ninja_prod | gzip > $BACKUP_DIR/lunch_ninja_$DATE.sql.gz

# Keep only last 30 days
find $BACKUP_DIR -name "lunch_ninja_*.sql.gz" -mtime +30 -delete
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/backup_lunch_ninja.sh

# Add to crontab
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup_lunch_ninja.sh
```

## Updates & Deployments

To deploy updates:

```bash
# Build new release locally
MIX_ENV=prod mix release

# Stop service
sudo systemctl stop lunch_ninja

# Upload new release
scp -r _build/prod/rel/lunch_ninja user@your-server:/opt/lunch_ninja_new

# Switch releases
sudo mv /opt/lunch_ninja /opt/lunch_ninja_old
sudo mv /opt/lunch_ninja_new /opt/lunch_ninja
sudo chown -R lunch_ninja:lunch_ninja /opt/lunch_ninja

# Run migrations
sudo -u lunch_ninja /opt/lunch_ninja/bin/lunch_ninja eval "LunchNinja.Release.migrate"

# Start service
sudo systemctl start lunch_ninja

# If successful, remove old release
sudo rm -rf /opt/lunch_ninja_old
```

## Troubleshooting

### Application won't start

```bash
# Check logs
sudo journalctl -u lunch_ninja -n 100

# Common issues:
# - Missing environment variables
# - Database connection issues
# - Port already in use
```

### Database connection errors

```bash
# Test PostgreSQL connection
psql -U lunch_ninja -d lunch_ninja_prod -h localhost

# Check if PostgreSQL is running
sudo systemctl status postgresql
```

### Email not sending

1. Verify RESEND_API_KEY is set correctly
2. Check Resend dashboard for API errors
3. Verify domain is verified in Resend
4. Check application logs for email errors

## Security Checklist

- [ ] SSL certificate installed and auto-renewal configured
- [ ] Firewall configured (UFW or iptables)
- [ ] Database uses strong password
- [ ] SECRET_KEY_BASE is unique and secure
- [ ] Regular security updates applied
- [ ] Database backups configured
- [ ] Environment variables not in version control
- [ ] Resend domain verified
- [ ] SSH key-based authentication enabled
- [ ] fail2ban installed for brute-force protection

## Performance Tuning

### Database Connection Pool

Adjust `POOL_SIZE` based on server resources:
- Small server (1-2 CPUs): 10
- Medium server (4 CPUs): 20
- Large server (8+ CPUs): 40

### Oban Job Queue

Monitor job performance in production:

```elixir
# In iex
Oban.check_queue(queue: :default)
```

## Support

For issues or questions:
- Email: mike@lunchninja.org
- GitHub: Create an issue in the repository
