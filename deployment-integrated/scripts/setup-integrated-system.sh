#!/bin/bash
set -e

# Captain JAX Integrated Content System - VPS Setup Script
# Combines Telegram inspiration collection with Twitter automation
# Usage: curl -s YOUR_URL/setup-integrated-system.sh | sudo bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Check root
[ "$EUID" -ne 0 ] && error "Please run as root: curl -s YOUR_URL/setup-integrated-system.sh | sudo bash"

BASE_URL="https://stellular-zuccutto-0bc90b.netlify.app"
# UPDATE THIS to your GitHub repository raw URL
# Format: https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main
# Example: https://raw.githubusercontent.com/johndoe/captain-jax-integrated/main
GITHUB_RAW="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main"

log "🚀 Captain JAX Integrated Content System - VPS Setup"

# Clear package locks
clear_package_locks() {
    log "Clearing package locks..."
    pkill -f apt || true
    pkill -f dpkg || true
    sleep 3
    rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock
    dpkg --configure -a || true
    success "Package locks cleared"
}

# Safe package installation
safe_apt_install() {
    local max_attempts=3
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        log "Installation attempt $attempt/$max_attempts..."
        if DEBIAN_FRONTEND=noninteractive apt install -y \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" "$@"; then
            success "Packages installed"
            return 0
        fi
        warning "Attempt $attempt failed"
        [ $attempt -lt $max_attempts ] && clear_package_locks && sleep 5
        ((attempt++))
    done
    error "Failed after $max_attempts attempts"
}

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

clear_package_locks

# Wait for automatic updates
log "Waiting for automatic updates..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    log "Package manager busy, waiting..."
    sleep 10
done

# Update system
log "Updating package lists..."
apt update || { clear_package_locks; apt update; }

# Install packages
log "Installing core tools..."
safe_apt_install curl wget git

log "Installing Python..."
safe_apt_install python3 python3-pip python3-venv

log "Installing web server..."
safe_apt_install nginx

log "Installing security tools..."
safe_apt_install ufw fail2ban

log "Installing utilities..."
safe_apt_install htop unzip

success "All system packages installed"

# Create user
log "Creating application user..."
if ! id "captain-jax" &>/dev/null; then
    useradd -m -s /bin/bash captain-jax
    usermod -aG sudo captain-jax
    success "User 'captain-jax' created"
else
    warning "User 'captain-jax' already exists"
fi

# Setup directories
log "Setting up application directory..."
APP_DIR="/home/captain-jax/tweet-automator"
mkdir -p "$APP_DIR"/{logs,config,templates,telegram/data}
chown -R captain-jax:captain-jax "$APP_DIR"
success "Directory structure created"

# Python virtual environment
log "Setting up Python environment..."
sudo -u captain-jax python3 -m venv "$APP_DIR/venv"
success "Virtual environment created"

# Download files
log "Downloading application files..."

download_file() {
    local url="$1"
    local output="$2"
    local desc="$3"
    if curl -sL --connect-timeout 30 --max-time 60 "$url" -o "$output"; then
        success "Downloaded $desc"
        return 0
    else
        error "Failed to download $desc from $url"
    fi
}

# Core application files (adapt URLs to your hosting)
download_file "$BASE_URL/enhanced_tweet_automator.py" "$APP_DIR/enhanced_tweet_automator.py" "Twitter automator"
download_file "$GITHUB_RAW/captain-jax-content/telegram/enhanced_automator_with_telegram.py" "$APP_DIR/enhanced_automator_with_telegram.py" "Integrated system"
download_file "$GITHUB_RAW/captain-jax-content/telegram/integration_bridge.py" "$APP_DIR/integration_bridge.py" "Integration bridge"
download_file "$GITHUB_RAW/captain-jax-content/telegram/telegram_bot.py" "$APP_DIR/telegram_bot.py" "Telegram bot"
download_file "$GITHUB_RAW/captain-jax-content/telegram/inspiration_collector.py" "$APP_DIR/inspiration_collector.py" "Inspiration collector"
download_file "$GITHUB_RAW/captain-jax-content/telegram/approval_workflow.py" "$APP_DIR/approval_workflow.py" "Approval workflow"
download_file "$GITHUB_RAW/captain-jax-content/telegram/feedback_handler.py" "$APP_DIR/feedback_handler.py" "Feedback handler"

# Templates
download_file "$BASE_URL/templates/axonn-tweet-templates.md" "$APP_DIR/templates/axonn-tweet-templates.md" "Axonn templates"
download_file "$BASE_URL/templates/enhanced-tweet-templates.md" "$APP_DIR/templates/enhanced-tweet-templates.md" "Enhanced templates"
download_file "$BASE_URL/templates/reply-cta-templates.md" "$APP_DIR/templates/reply-cta-templates.md" "Reply templates"

# Configuration templates
cat > "$APP_DIR/.env.template" << 'EOF'
# Twitter API Credentials
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret
TWITTER_ACCESS_TOKEN=your_access_token
TWITTER_ACCESS_TOKEN_SECRET=your_access_token_secret
TWITTER_BEARER_TOKEN=your_bearer_token

# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_USER_ID=your_telegram_user_id

# Venice AI (Optional - for image generation)
VENICE_API_KEY=your_venice_api_key

# System Configuration
TEST_MODE=false
POSTS_PER_DAY=3
POSTING_TIMES=09:00,15:00,21:00
IMAGE_GENERATION=true
APPROVAL_MODE=optional
EOF

cat > "$APP_DIR/config/telegram_config.json" << 'EOF'
{
  "bot_token": "ENV:TELEGRAM_BOT_TOKEN",
  "authorized_users": ["ENV:TELEGRAM_USER_ID"],
  "approval_mode": "optional",
  "check_in_times": ["08:00", "18:00"],
  "approval_timeout_hours": 2,
  "feedback_delay_hours": 2,
  "approval_window": {
    "start_hour": 7,
    "end_hour": 22
  },
  "content_filters": {
    "require_approval_for": ["promotional", "announcement"],
    "auto_approve": ["educational", "community"],
    "always_review": ["external_links", "mentions"]
  }
}
EOF

chown -R captain-jax:captain-jax "$APP_DIR"

# Install Python dependencies
log "Installing Python dependencies..."
cat > "$APP_DIR/requirements.txt" << 'EOF'
tweepy>=4.14.0
python-telegram-bot>=20.0
python-dotenv>=1.0.0
schedule>=1.2.0
requests>=2.31.0
Pillow>=10.4.0
flask>=3.0.0
aiohttp>=3.9.0
asyncio
EOF

sudo -u captain-jax "$APP_DIR/venv/bin/pip" install --upgrade pip --quiet
sudo -u captain-jax "$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt" --quiet
success "Python dependencies installed"

# Configure firewall
log "Configuring firewall..."
if ! ufw status | grep -q "Status: active"; then
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 'Nginx Full'
    ufw --force enable
    success "Firewall configured"
fi

# Configure fail2ban
systemctl enable fail2ban >/dev/null 2>&1 || true
systemctl start fail2ban >/dev/null 2>&1 || true

# Nginx configuration
log "Creating nginx configuration..."
cat > /etc/nginx/sites-available/captain-jax-integrated << 'EOF'
server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 30s;
        proxy_read_timeout 30s;
    }

    location /health {
        proxy_pass http://localhost:8080/health;
        proxy_connect_timeout 10s;
        proxy_read_timeout 10s;
    }

    location /telegram_status {
        proxy_pass http://localhost:8080/telegram_status;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/captain-jax-integrated /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
success "Nginx configured"

# Systemd service
log "Creating systemd service..."
cat > /etc/systemd/system/captain-jax-integrated.service << EOF
[Unit]
Description=Captain JAX Integrated Content System
After=network.target

[Service]
Type=simple
User=captain-jax
Group=captain-jax
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/python3 $APP_DIR/enhanced_automator_with_telegram.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=captain-jax-integrated

# Security
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable captain-jax-integrated
success "Systemd service created"

# Monitoring script
cat > "$APP_DIR/monitor.sh" << 'EOF'
#!/bin/bash
case "${1:-status}" in
    status)
        echo "📊 Captain JAX Integrated System Status"
        echo "========================================"
        systemctl status captain-jax-integrated --no-pager -l
        echo ""
        echo "🏥 Health Check:"
        curl -s http://localhost:8080/health 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Not responding"
        echo ""
        echo "📱 Telegram Status:"
        curl -s http://localhost:8080/telegram_status 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Not responding"
        ;;
    logs)
        journalctl -u captain-jax-integrated -n 50 --no-pager
        ;;
    follow)
        journalctl -u captain-jax-integrated -f
        ;;
    restart)
        sudo systemctl restart captain-jax-integrated
        sleep 3
        systemctl status captain-jax-integrated --no-pager -l
        ;;
    start)
        sudo systemctl start captain-jax-integrated
        sleep 3
        systemctl status captain-jax-integrated --no-pager -l
        ;;
    stop)
        sudo systemctl stop captain-jax-integrated
        ;;
    test)
        sudo -u captain-jax $APP_DIR/venv/bin/python $APP_DIR/enhanced_automator_with_telegram.py --test
        ;;
    *)
        echo "Usage: $0 {status|logs|follow|restart|start|stop|test}"
        ;;
esac
EOF

chmod +x "$APP_DIR/monitor.sh"
chown captain-jax:captain-jax "$APP_DIR/monitor.sh"
success "Monitoring script created"

# Get server IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")

log "🎉 Installation completed successfully!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔑 Configure environment variables:"
echo "   nano /home/captain-jax/tweet-automator/.env"
echo ""
echo "   Required variables:"
echo "   - TWITTER_API_KEY, TWITTER_API_SECRET"
echo "   - TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET, TWITTER_BEARER_TOKEN"
echo "   - TELEGRAM_BOT_TOKEN (from @BotFather)"
echo "   - TELEGRAM_USER_ID (from @userinfobot)"
echo "   - VENICE_API_KEY (optional, for images)"
echo ""
echo "2. 🧪 Test the system:"
echo "   /home/captain-jax/tweet-automator/monitor.sh test"
echo ""
echo "3. 🚀 Start the service:"
echo "   systemctl start captain-jax-integrated"
echo ""
echo "4. 📊 Monitor:"
echo "   /home/captain-jax/tweet-automator/monitor.sh status"
echo ""
echo "5. 🌐 Health endpoint:"
echo "   curl http://$SERVER_IP/health"
echo ""
echo "6. 📱 Test Telegram bot:"
echo "   Send /start to your bot"
echo ""
success "Captain JAX Integrated System ready! ⚓🚢"
