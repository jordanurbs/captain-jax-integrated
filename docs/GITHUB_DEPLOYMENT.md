# GitHub Deployment Guide - Captain JAX Integrated System

## 🚀 Quick Setup (5 Minutes)

### Step 1: Create GitHub Repository

```bash
# Navigate to your project
cd /Users/jordanurbs/Downloads/content-inspiration

# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Captain JAX integrated content system"
```

**On GitHub:**
1. Go to https://github.com/new
2. Create repository (e.g., `captain-jax-integrated`)
3. **Important**: Make it **Public** (required for raw file access)
4. Don't initialize with README (you already have files)

```bash
# Link your local repo to GitHub
git remote add origin https://github.com/YOUR_USERNAME/captain-jax-integrated.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

### Step 2: Update Deployment Script with Your GitHub URL

**Edit the setup script:**
```bash
nano deployment-integrated/scripts/setup-integrated-system.sh
```

**Find line 13 and update:**
```bash
# BEFORE (line 13):
GITHUB_RAW="https://raw.githubusercontent.com/YOUR_REPO/main"

# AFTER (replace with YOUR username and repo):
GITHUB_RAW="https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main"
```

**Commit and push the change:**
```bash
git add deployment-integrated/scripts/setup-integrated-system.sh
git commit -m "Update GitHub raw URL to actual repository"
git push
```

---

### Step 3: Deploy to VPS

**Now you can deploy with one command:**
```bash
# SSH into your VPS
ssh root@your-vps-ip

# Run the deployment script directly from GitHub
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash
```

**The script will automatically download:**
- All Python files from your repository
- Configuration templates
- Template files
- Systemd service definition

---

## 📋 Complete Deployment Flow

### Repository Structure on GitHub

After pushing, your GitHub repo will have:
```
captain-jax-integrated/
├── .gitignore                                    ← Protects secrets
├── deployment-integrated/
│   ├── README.md                                 ← Quick start
│   ├── INTEGRATION_SUMMARY.md                    ← Overview
│   ├── .env.template                             ← Configuration template
│   ├── requirements-integrated.txt               ← Dependencies
│   ├── scripts/
│   │   └── setup-integrated-system.sh           ← **Main deployment script**
│   ├── config/
│   │   └── telegram_config.json                 ← Bot configuration
│   ├── systemd/
│   │   └── captain-jax-integrated.service       ← Service definition
│   └── docs/
│       ├── DEPLOY.md                             ← Full guide
│       └── GITHUB_DEPLOYMENT.md                  ← This file
├── captain-jax-content/
│   ├── telegram/
│   │   ├── enhanced_automator_with_telegram.py  ← Main application
│   │   ├── integration_bridge.py                ← Telegram integration
│   │   └── ...
│   └── deployment/netlify-bootstrap/public/
│       └── enhanced_tweet_automator.py          ← Core automation
└── content_inspiration.py                        ← Original simple bot
```

---

### What Happens During Deployment

**The setup script downloads files via GitHub raw URLs:**
```bash
# Example downloads from your repo:
https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main/captain-jax-content/telegram/enhanced_automator_with_telegram.py
https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main/deployment-integrated/requirements-integrated.txt
https://raw.githubusercontent.com/YOUR_USERNAME/captain-jax-integrated/main/deployment-integrated/.env.template
```

**Why raw.githubusercontent.com?**
- Direct file access without HTML wrapper
- Works with `curl` and `wget`
- No authentication needed for public repos

---

## 🔐 Security Best Practices

### ✅ Files Safe to Commit (Already in Repo)
- `.env.template` - Template only, no real credentials
- `telegram_config.json` - No secrets, just settings
- All `.py` files - No hardcoded secrets
- Documentation files

### ❌ Files to NEVER Commit (Protected by .gitignore)
- `.env` - **CONTAINS REAL CREDENTIALS**
- `config/.env` - Environment files
- `telegram/data/` - User data
- `logs/` - Log files
- `*.db` - Database files

### Your .gitignore (Already Created)
The `.gitignore` file protects:
- All `.env` files (except `.env.template`)
- API keys and tokens
- Data directories
- Log files
- Python cache files

---

## 🎯 Step-by-Step Deployment Example

### Example with username "johndoe" and repo "captain-jax-bot"

**1. Create GitHub Repo:**
```bash
cd /Users/jordanurbs/Downloads/content-inspiration
git init
git add .
git commit -m "Initial commit: Captain JAX integrated system"
```

On GitHub: Create repo `captain-jax-bot` (Public)

```bash
git remote add origin https://github.com/johndoe/captain-jax-bot.git
git branch -M main
git push -u origin main
```

**2. Update Setup Script (Line 13):**
```bash
nano deployment-integrated/scripts/setup-integrated-system.sh

# Change:
GITHUB_RAW="https://raw.githubusercontent.com/YOUR_REPO/main"

# To:
GITHUB_RAW="https://raw.githubusercontent.com/johndoe/captain-jax-bot/main"
```

**3. Commit and Push:**
```bash
git add deployment-integrated/scripts/setup-integrated-system.sh
git commit -m "Update GitHub URL to johndoe/captain-jax-bot"
git push
```

**4. Deploy to VPS:**
```bash
ssh root@your-vps-ip

curl -sL https://raw.githubusercontent.com/johndoe/captain-jax-bot/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash
```

**5. Configure Credentials:**
```bash
nano /home/captain-jax/tweet-automator/.env

# Add your real credentials:
TWITTER_API_KEY=your_real_twitter_key
TELEGRAM_BOT_TOKEN=7972653788:AAHY-5gsL5iuxHRPp7iUlB7hvCYqnJL2aWI
TELEGRAM_USER_ID=236258123
```

**6. Start Service:**
```bash
systemctl start captain-jax-integrated
systemctl status captain-jax-integrated
```

---

## 🔄 Updating Your Deployment

### After Making Code Changes

**On your local machine:**
```bash
# Make changes to files
git add .
git commit -m "Description of changes"
git push
```

**On your VPS:**
```bash
# Re-run the setup script to pull latest changes
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash

# Or manually update specific files:
cd /home/captain-jax/tweet-automator
sudo -u captain-jax curl -o enhanced_automator_with_telegram.py \
  https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/captain-jax-content/telegram/enhanced_automator_with_telegram.py

# Restart service
systemctl restart captain-jax-integrated
```

---

## 🚨 Troubleshooting

### "Script downloads fail with 404"

**Check your GitHub URL:**
```bash
# Test the URL directly:
curl -I https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deployment-integrated/scripts/setup-integrated-system.sh

# Should return: HTTP/2 200
# If 404: Check username, repo name, branch name
```

**Common mistakes:**
- ❌ `github.com` instead of `raw.githubusercontent.com`
- ❌ Wrong branch name (using `master` instead of `main`)
- ❌ Private repository (must be public for raw access)
- ❌ Typo in username or repository name

### "Repository is private"

**Option 1: Make public**
- Go to repo Settings → Danger Zone → Change visibility → Public

**Option 2: Use personal access token** (advanced)
```bash
# Generate token at: https://github.com/settings/tokens
# Then use:
curl -H "Authorization: token YOUR_GITHUB_TOKEN" \
  https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/path/to/file
```

### "Credentials exposed in Git history"

**If you accidentally committed .env:**
```bash
# Remove from current version
git rm --cached .env
git commit -m "Remove .env from tracking"
git push

# Verify .gitignore includes .env
grep "^.env$" .gitignore

# For complete cleanup (advanced):
# Use git-filter-repo or BFG Repo-Cleaner
# Then rotate all compromised credentials immediately!
```

---

## ✅ Deployment Checklist

- [ ] Created public GitHub repository
- [ ] Pushed all code to GitHub
- [ ] Verified `.gitignore` protects `.env` files
- [ ] Updated `GITHUB_RAW` URL in setup script (line 13)
- [ ] Committed and pushed setup script changes
- [ ] Tested raw URL access to setup script
- [ ] Provisioned VPS (Ubuntu 20.04+)
- [ ] Ran deployment script on VPS
- [ ] Created `.env` with real credentials on VPS
- [ ] Started systemd service
- [ ] Verified bot responds to `/start` on Telegram
- [ ] Confirmed health endpoint works

---

## 🎉 Success!

Your system is now:
- ✅ Hosted on GitHub
- ✅ Deployable with one command
- ✅ Updateable via git push
- ✅ Secure (no credentials in repo)
- ✅ Running 24/7 on VPS

**Deployment URL:**
```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash
```

⚓ **Set sail with Captain JAX!** 🚢
