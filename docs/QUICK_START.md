# 🚀 Quick Start: 5-Minute GitHub Deployment

## Step 1: Push to GitHub (2 minutes)

```bash
cd /Users/jordanurbs/Downloads/content-inspiration

# Initialize git
git init
git add .
git commit -m "Initial commit: Captain JAX integrated system"

# Create repo on GitHub (https://github.com/new)
# Name: captain-jax-integrated
# Visibility: Public ⚠️ MUST be public for deployment script

# Link and push
git remote add origin https://github.com/YOUR_USERNAME/captain-jax-integrated.git
git branch -M main
git push -u origin main
```

## Step 2: Update Deployment Script (1 minute)

```bash
# Edit the setup script
nano deployment-integrated/scripts/setup-integrated-system.sh

# Update line 27 with YOUR GitHub username and repo:
GITHUB_RAW="https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main"
```

Example:
```bash
# If your username is "johndoe":
GITHUB_RAW="https://raw.githubusercontent.com/johndoe/captain-jax-integrated/main"
```

```bash
# Commit and push the change
git add deployment-integrated/scripts/setup-integrated-system.sh
git commit -m "Update GitHub URL for deployment"
git push
```

## Step 3: Deploy to VPS (2 minutes)

```bash
# SSH into your VPS
ssh root@YOUR_VPS_IP

# Run deployment script from GitHub
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash

# Configure credentials
nano /home/captain-jax/tweet-automator/.env
# Add your Twitter API keys, Telegram bot token, etc.

# Start the service
systemctl start captain-jax-integrated
```

## ✅ Verify It Works

```bash
# Check service status
systemctl status captain-jax-integrated

# Check health endpoint
curl http://YOUR_VPS_IP/health

# Send /start to your Telegram bot
# You should get a welcome message!
```

## 🎯 That's It!

Your bot is now:
- ✅ Running 24/7 on VPS
- ✅ Capturing inspiration via Telegram
- ✅ Posting tweets automatically
- ✅ Hosted on GitHub for easy updates

---

**Full Guide**: [GITHUB_DEPLOYMENT.md](GITHUB_DEPLOYMENT.md)
