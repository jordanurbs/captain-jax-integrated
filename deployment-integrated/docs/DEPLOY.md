# Captain JAX Integrated Content System - Deployment Guide

## 🎯 What This System Does

**Combines two powerful systems:**
1. **Telegram Inspiration Bot** - Captures your content ideas in real-time
2. **Twitter Automation** - Generates and posts tweets automatically using 110+ templates

**End-to-end workflow:**
- You share ideas with Telegram bot throughout the day
- Bot captures inspiration and analyzes themes
- At scheduled times (9am, 3pm, 9pm), system generates tweets using your inspiration
- Optionally get approval via Telegram before posting
- Auto-posts to Twitter with images
- 2-4 hours later, posts reply with CTA (if enabled)
- Tracks performance and learns from feedback

## 🚀 Quick Start (VPS Deployment)

### Prerequisites
- Ubuntu 20.04+ VPS (DigitalOcean, Vultr, Linode, etc.)
- Root SSH access
- Twitter Developer Account with API credentials
- Telegram bot token (from @BotFather)

### Step 1: Prepare Credentials

**Twitter API** (get from https://developer.twitter.com):
- API Key & Secret
- Access Token & Secret
- Bearer Token

**Telegram Bot** (create via @BotFather):
1. Open Telegram, search `@BotFather`
2. Send `/newbot` and follow prompts
3. Save the bot token

**Your Telegram User ID** (get from @userinfobot):
1. Search `@userinfobot` on Telegram
2. Start conversation, copy your ID

### Step 2: Deploy to VPS

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Download and run setup script
curl -sL https://raw.githubusercontent.com/YOUR_REPO/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash
```

**Note**: Update the `GITHUB_RAW` URL in the script to point to your actual repository.

### Step 3: Configure Environment

```bash
# Edit configuration file
nano /home/captain-jax/tweet-automator/.env

# Add your credentials (see template below)
```

**Environment file template:**
```bash
# Twitter
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret
TWITTER_ACCESS_TOKEN=your_access_token
TWITTER_ACCESS_TOKEN_SECRET=your_access_token_secret
TWITTER_BEARER_TOKEN=your_bearer_token

# Telegram
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
TELEGRAM_USER_ID=123456789

# Venice AI (optional - for images)
VENICE_API_KEY=your_venice_api_key

# Configuration
TEST_MODE=false
POSTS_PER_DAY=3
POSTING_TIMES=09:00,15:00,21:00
IMAGE_GENERATION=true
APPROVAL_MODE=optional
```

### Step 4: Test the System

```bash
# Test without posting to Twitter
/home/captain-jax/tweet-automator/monitor.sh test

# Expected output: Template loading, Telegram connection, health checks
```

### Step 5: Start Service

```bash
# Start the service
systemctl start captain-jax-integrated

# Enable auto-start on boot
systemctl enable captain-jax-integrated

# Check status
/home/captain-jax/tweet-automator/monitor.sh status
```

### Step 6: Verify Everything Works

```bash
# 1. Check health endpoint
curl http://your-vps-ip/health

# 2. Check Telegram status
curl http://your-vps-ip/telegram_status

# 3. Send /start to your Telegram bot
# Open Telegram and send: /start

# 4. Try inspiration command
# In Telegram send: /inspire
# Then share an idea

# 5. Check logs
/home/captain-jax/tweet-automator/monitor.sh logs
```

## 📱 Using the System

### Telegram Commands

```
/start       - Initialize bot and see welcome message
/help        - Show all available commands
/inspire     - Submit content inspiration
/pause       - Pause automatic tweet posting
/resume      - Resume automatic posting
/status      - View system status and next post time
/analytics   - Get performance report
/boost       - Boost priority of next tweet
```

### Daily Workflow

**Morning (8:00 AM)**
- Bot sends check-in: "Any inspiring ideas or lessons learned?"
- You respond with ideas, experiences, or observations
- Bot captures and analyzes your inspiration

**Throughout Day (9 AM, 3 PM, 9 PM)**
- System generates tweet using templates + your inspiration
- If `APPROVAL_MODE=required`: Sends to Telegram for approval
- If `APPROVAL_MODE=optional`: Posts automatically, notifies you
- If `APPROVAL_MODE=disabled`: Silent auto-posting

**2-4 Hours After Tweet**
- Posts reply with relevant CTA (if enabled)
- Tracks engagement metrics

**Evening (6:00 PM)**
- Bot sends daily summary
- Request feedback on posted content
- Shows analytics and performance

### Approval Flow (if enabled)

When bot sends tweet for approval:

```
🐦 Tweet Preview
━━━━━━━━━━━━━━━━
Content: [Generated tweet text]
Image: [Preview if enabled]
Theme: Monday Navigation
Type: Educational

Actions:
✅ Approve - Post immediately
✏️ Edit - Modify before posting
⏰ Schedule - Post at specific time
❌ Reject - Skip this tweet
```

**Telegram Buttons:**
- Tap ✅ to approve and post
- Tap ✏️ to edit content
- Tap ⏰ to schedule for later
- Tap ❌ to skip

### Providing Inspiration

**Method 1: Respond to check-ins**
```
Bot: ☀️ Good morning! Any inspiring ideas?
You: Just learned about async patterns in Python.
     Game changer for handling multiple API calls!
```

**Method 2: Use /inspire command**
```
You: /inspire
Bot: Share your inspiration!
You: Client asked for real-time updates.
     Built it with WebSockets instead of polling.
     50x performance improvement!
```

**Method 3: Natural messages** (if keywords detected)
```
You: Building a new feature that automates data validation.
     Really exciting to see it catch errors before production!

Bot: 🎯 Captured inspiration!
     Generated 3 tweet ideas:
     1. [Tweet preview...]
     2. [Tweet preview...]
     3. [Tweet preview...]
```

## 🔧 Configuration Options

### Approval Modes

**`disabled`** - Full automation
- Auto-posts without any approval
- Best for: Fully trusting the system

**`optional`** - Notify but don't block (recommended)
- Auto-posts immediately
- Sends notification to Telegram
- You can still pause/resume anytime
- Best for: Maintaining control with convenience

**`required`** - Manual approval
- Waits for your approval before posting
- 2-hour timeout (auto-skip if no response)
- Best for: High-stakes accounts

### Posting Schedule

Edit in `.env`:
```bash
POSTS_PER_DAY=3
POSTING_TIMES=09:00,15:00,21:00

# Or spread throughout day:
POSTS_PER_DAY=5
POSTING_TIMES=08:00,11:00,14:00,17:00,20:00
```

### Content Distribution

Templates are categorized and rotated:
- 15% Short punchy (under 100 chars)
- 25% Medium educational (100-300 chars)
- 12% Long threads (5-8 tweets)
- 25% Soft CTAs (natural mentions)
- 15% Direct CTAs (promotional)
- 8% Axonn premium formulas

### Image Generation

```bash
# Enable/disable images
IMAGE_GENERATION=true

# Requires Venice AI API key
VENICE_API_KEY=your_key

# Image styles rotate:
# - 16-bit pixel art (30%)
# - Minimalist tech (25%)
# - Nautical tech (20%)
# - Data visualization (15%)
# - Atmospheric (10%)
```

### Reply CTAs

```bash
# Enable promotional follow-ups
REPLY_CTAS=true

# System waits 2-4 hours after main tweet
# Then posts contextual CTA as reply
# Matches CTA to content type
```

## 📊 Monitoring & Analytics

### Real-time Monitoring

```bash
# System status
/home/captain-jax/tweet-automator/monitor.sh status

# Live logs
/home/captain-jax/tweet-automator/monitor.sh follow

# Health check
curl http://your-vps-ip/health
```

### Performance Reports

**Via Telegram:**
```
/analytics
```

**Via Web:**
```bash
curl http://your-vps-ip/performance_report | jq
```

**Via Files:**
```bash
# Performance metrics
cat /home/captain-jax/tweet-automator/telegram/data/performance_metrics.json

# Inspiration history
cat /home/captain-jax/tweet-automator/telegram/data/inspirations.json

# Approval history
cat /home/captain-jax/tweet-automator/telegram/data/approval_history.json
```

### Key Metrics Tracked

- Tweets posted vs scheduled
- Approval rate and response time
- Template usage distribution
- Engagement rate per template type
- Inspiration usage statistics
- Feedback sentiment analysis
- CTA conversion tracking

## 🚨 Troubleshooting

### Service Won't Start

```bash
# Check logs
journalctl -u captain-jax-integrated -n 50

# Common issues:
# 1. Missing .env file
ls -la /home/captain-jax/tweet-automator/.env

# 2. Invalid credentials
# Verify Twitter API keys at https://developer.twitter.com

# 3. Python dependencies
sudo -u captain-jax /home/captain-jax/tweet-automator/venv/bin/pip install -r requirements.txt
```

### Telegram Bot Not Responding

```bash
# 1. Check bot token
grep TELEGRAM_BOT_TOKEN /home/captain-jax/tweet-automator/.env

# 2. Verify user ID is authorized
cat /home/captain-jax/tweet-automator/config/telegram_config.json | grep authorized_users

# 3. Test bot directly
curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe
```

### Tweets Not Posting

```bash
# Check test mode
grep TEST_MODE /home/captain-jax/tweet-automator/.env
# Should be: TEST_MODE=false

# Verify Twitter credentials
# Check logs for API errors
journalctl -u captain-jax-integrated | grep -i twitter

# Test posting manually
sudo -u captain-jax /home/captain-jax/tweet-automator/venv/bin/python \
  /home/captain-jax/tweet-automator/enhanced_automator_with_telegram.py --post-now
```

### Images Not Generating

```bash
# Check Venice API key
grep VENICE_API_KEY /home/captain-jax/tweet-automator/.env

# Verify IMAGE_GENERATION is enabled
grep IMAGE_GENERATION /home/captain-jax/tweet-automator/.env

# Test image generation
# Check logs for Venice API errors
journalctl -u captain-jax-integrated | grep -i venice
```

## 🔐 Security Best Practices

1. **Never commit `.env` with real credentials**
2. **Use strong SSH keys** for VPS access
3. **Keep bot token secret** - never share publicly
4. **Rotate API keys regularly** - every 90 days
5. **Monitor authorized_users** - only trusted individuals
6. **Enable firewall** - ufw is configured automatically
7. **Keep system updated** - `apt update && apt upgrade`
8. **Review logs regularly** - watch for unusual activity

## 📈 Optimization Tips

### Improve Content Quality

1. **Provide diverse inspiration** - Share various topics
2. **Rate content honestly** - Helps system learn
3. **Edit poor tweets** - Improves template selection
4. **Use /boost** - Prioritize important content

### Increase Engagement

1. **Post at optimal times** - Test different schedules
2. **Balance content types** - Mix value and promotion
3. **Use images strategically** - Not every tweet needs one
4. **Monitor analytics** - Double down on what works

### Maintain System Health

1. **Respond to check-ins** - Fresh inspiration = better content
2. **Review approvals promptly** - Don't let queue build up
3. **Check status daily** - Catch issues early
4. **Update templates** - Add seasonal or trending topics

## 🆘 Support & Resources

### Log Locations
```
/home/captain-jax/tweet-automator/logs/
├── captain_jax.log               # Main application log
├── telegram_bot.log              # Telegram bot interactions
├── twitter_api.log               # Twitter API calls
└── performance_metrics.json      # Analytics data
```

### Configuration Files
```
/home/captain-jax/tweet-automator/
├── .env                          # Credentials (create from template)
├── config/telegram_config.json   # Telegram bot settings
└── templates/                    # Tweet templates
    ├── axonn-tweet-templates.md
    ├── enhanced-tweet-templates.md
    └── reply-cta-templates.md
```

### Useful Commands
```bash
# Restart service
systemctl restart captain-jax-integrated

# Stop service
systemctl stop captain-jax-integrated

# View status
/home/captain-jax/tweet-automator/monitor.sh status

# Follow logs live
/home/captain-jax/tweet-automator/monitor.sh follow

# Test system
/home/captain-jax/tweet-automator/monitor.sh test
```

## 🚀 Advanced Features

### Custom Template Rules

Edit `config/telegram_config.json`:
```json
{
  "custom_rules": [
    {
      "name": "Product launches need approval",
      "condition": "contains_hashtag",
      "value": "#launch",
      "action": "require_approval"
    },
    {
      "name": "Educational threads auto-approve",
      "condition": "is_thread",
      "value": "educational",
      "action": "auto_approve"
    }
  ]
}
```

### Multi-User Approval (Enterprise)

```json
{
  "multi_user_approval": {
    "enabled": true,
    "min_approvals_needed": 2,
    "voting_enabled": true,
    "authorized_users": ["user_id_1", "user_id_2", "user_id_3"]
  }
}
```

### Scheduled Reports

```json
{
  "scheduled_reports": {
    "daily_summary": "18:00",
    "weekly_report": "monday 09:00",
    "monthly_deep_dive": "first_monday 10:00"
  }
}
```

### Webhook Integrations

```json
{
  "integration_hooks": {
    "pre_post_webhook": "https://your-webhook.com/pre-post",
    "post_post_webhook": "https://your-webhook.com/post-post",
    "feedback_webhook": "https://your-webhook.com/feedback"
  }
}
```

## ✅ Post-Deployment Checklist

- [ ] VPS deployed and accessible via SSH
- [ ] Setup script executed successfully
- [ ] `.env` file configured with all credentials
- [ ] Service started: `systemctl status captain-jax-integrated`
- [ ] Health endpoint responding: `curl http://vps-ip/health`
- [ ] Telegram bot responding to `/start`
- [ ] Test tweet posted successfully
- [ ] Inspiration capture working
- [ ] Approval flow tested (if enabled)
- [ ] Analytics accessible via `/analytics`
- [ ] Logs are clean and error-free
- [ ] Auto-restart verified: `systemctl restart captain-jax-integrated`
- [ ] Monitoring script works: `monitor.sh status`

---

## 🎉 Success!

Your integrated content system is now running 24/7, automatically:
- ✅ Capturing your inspiration via Telegram
- ✅ Generating engaging tweets using 110+ templates
- ✅ Posting to Twitter on schedule
- ✅ Managing approvals (if enabled)
- ✅ Tracking performance and learning
- ✅ Providing daily analytics

**Next steps:** Start sharing your ideas with the bot and watch your Twitter presence grow on autopilot!

⚓ **Set sail with Captain JAX!** 🚢
