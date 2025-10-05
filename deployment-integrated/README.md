# Captain JAX Integrated Content System

> **Telegram Inspiration Capture + Automated Twitter Posting = Content Creation on Autopilot**

## 🎯 What This Does

This system integrates two powerful tools:

1. **Telegram Bot** - Captures your content inspiration in real-time throughout the day
2. **Twitter Automation** - Generates and posts engaging tweets using 110+ professional templates

**Your workflow:**
```
You → Share idea in Telegram
Bot → Analyzes and stores inspiration
System → Generates tweet using templates + your inspiration
(Optional) → You approve via Telegram
Bot → Posts to Twitter automatically
Bot → Tracks performance and learns
```

## ✨ Key Features

- ✅ **24/7 Inspiration Capture** - Telegram bot always listening
- ✅ **Smart Tweet Generation** - 110+ templates (Axonn premium + custom)
- ✅ **Automatic Posting** - Scheduled tweets (3/day default)
- ✅ **Human-in-the-Loop** - Optional approval workflow
- ✅ **AI Image Generation** - Venice AI integration
- ✅ **Reply CTAs** - Promotional follow-ups 2-4 hours later
- ✅ **Performance Tracking** - Analytics and learning
- ✅ **Daily Check-ins** - Bot prompts for ideas at 8am & 6pm

## 🚀 Quick Start

### 1. Get Credentials

**Twitter API** (https://developer.twitter.com):
- Create app and get API keys
- Need: API Key, API Secret, Access Token, Access Secret, Bearer Token

**Telegram Bot** (@BotFather):
- Send `/newbot` to @BotFather
- Follow prompts and save bot token

**Your Telegram ID** (@userinfobot):
- Send `/start` to @userinfobot
- Copy your user ID

### 2. Deploy to VPS

```bash
# SSH into your Ubuntu VPS
ssh root@your-vps-ip

# Run deployment script
curl -sL https://raw.githubusercontent.com/YOUR_REPO/main/deployment-integrated/scripts/setup-integrated-system.sh | sudo bash
```

### 3. Configure

```bash
# Edit environment variables
nano /home/captain-jax/tweet-automator/.env

# Add your credentials (Twitter, Telegram, Venice AI)
```

### 4. Start

```bash
# Start the service
systemctl start captain-jax-integrated

# Check status
/home/captain-jax/tweet-automator/monitor.sh status

# Test Telegram bot
# Open Telegram and send: /start
```

## 📱 Telegram Commands

```
/start       - Initialize and see welcome
/inspire     - Submit content idea
/pause       - Pause auto-posting
/resume      - Resume auto-posting
/status      - View system status
/analytics   - Performance report
/boost       - Prioritize next tweet
/help        - Show all commands
```

## 📁 What's Included

```
deployment-integrated/
├── scripts/
│   └── setup-integrated-system.sh    # VPS deployment script
├── config/
│   └── telegram_config.json          # Telegram bot configuration
├── systemd/
│   └── captain-jax-integrated.service # Systemd service file
├── docs/
│   └── DEPLOY.md                     # Complete deployment guide
├── .env.template                      # Environment variables template
├── requirements-integrated.txt        # Python dependencies
└── README.md                          # This file
```

## 🔧 Configuration Options

### Approval Modes

- **`disabled`** - Auto-post everything
- **`optional`** - Auto-post, notify in Telegram (recommended)
- **`required`** - Wait for approval before posting

### Posting Schedule

```bash
POSTS_PER_DAY=3
POSTING_TIMES=09:00,15:00,21:00
```

### Image Generation

```bash
IMAGE_GENERATION=true
VENICE_API_KEY=your_key
```

### Content Distribution

- 15% Short punchy tweets
- 25% Medium educational
- 12% Long threads
- 25% Soft CTAs
- 15% Direct CTAs
- 8% Axonn premium formulas

## 📊 Monitoring

```bash
# System status
/home/captain-jax/tweet-automator/monitor.sh status

# Live logs
/home/captain-jax/tweet-automator/monitor.sh follow

# Health check
curl http://your-vps-ip/health

# Telegram status
curl http://your-vps-ip/telegram_status
```

## 🎓 How It Works

### Daily Workflow

**8:00 AM** - Morning check-in
```
Bot: ☀️ Good morning! Any inspiring ideas today?
You: Just figured out how to optimize our database queries
Bot: 🎯 Captured! This could make a great educational tweet
```

**9:00 AM** - First scheduled tweet
```
System: Generates tweet using your inspiration + templates
Bot: 🐦 Tweet Preview: "Database optimization tip: ..."
     ✅ Approve  ✏️ Edit  ❌ Reject
You: [Tap ✅]
Bot: ✅ Posted! Check Twitter
```

**11:00 AM** - Reply CTA posted
```
System: Posts promotional reply to main tweet
Bot: 💬 Reply posted: "Want to learn more? Check out..."
```

**6:00 PM** - Evening summary
```
Bot: 📊 Daily Summary
     3 tweets posted
     156 impressions
     12 engagements
     Template performance: Educational +15%
```

### Behind the Scenes

1. **Inspiration Collection**
   - Monitors Telegram for keywords
   - Daily check-ins at scheduled times
   - Stores ideas with metadata

2. **Tweet Generation**
   - Selects template based on daily theme
   - Incorporates recent inspiration
   - Adds relevant variables
   - Generates image (if enabled)

3. **Approval (Optional)**
   - Sends preview to Telegram
   - Waits for approval (2-hour timeout)
   - Editable before posting

4. **Publishing**
   - Posts to Twitter via API
   - Schedules reply CTA (if enabled)
   - Tracks posting metadata

5. **Analytics**
   - Monitors engagement
   - Updates template scores
   - Learns from feedback

## 🚨 Troubleshooting

### Service won't start
```bash
journalctl -u captain-jax-integrated -n 50
```

### Bot not responding
```bash
# Check token
grep TELEGRAM_BOT_TOKEN /home/captain-jax/tweet-automator/.env

# Test bot
curl https://api.telegram.org/bot<TOKEN>/getMe
```

### Tweets not posting
```bash
# Verify test mode is off
grep TEST_MODE /home/captain-jax/tweet-automator/.env
# Should be: TEST_MODE=false
```

## 📚 Documentation

- **[DEPLOY.md](docs/DEPLOY.md)** - Complete deployment guide
- **[.env.template](.env.template)** - All configuration options
- **[telegram_config.json](config/telegram_config.json)** - Bot settings

## 🔐 Security

- Never commit `.env` with real credentials
- Keep bot token secret
- Use SSH keys for VPS access
- Rotate API keys every 90 days
- Monitor authorized users list
- Review logs regularly

## 📈 Tips for Success

1. **Be consistent with inspiration** - Share ideas daily
2. **Respond to check-ins** - Fresh content = better tweets
3. **Review analytics weekly** - Double down on what works
4. **Rate content honestly** - Helps system learn
5. **Edit poor tweets** - Improves future generation

## 🆘 Support

- Check logs: `monitor.sh logs`
- Health status: `monitor.sh status`
- Test mode: `monitor.sh test`
- Full guide: [docs/DEPLOY.md](docs/DEPLOY.md)

## ✅ Success Checklist

After deployment:

- [ ] Service is running: `systemctl status captain-jax-integrated`
- [ ] Health endpoint works: `curl http://vps-ip/health`
- [ ] Telegram bot responds to `/start`
- [ ] Test tweet posted successfully
- [ ] Inspiration capture working
- [ ] Analytics accessible
- [ ] Logs are clean

## 🎉 You're Ready!

Your content system is now running 24/7, automatically capturing your inspiration and turning it into engaging Twitter content.

**Start by sending `/start` to your Telegram bot!**

⚓ **Happy sailing with Captain JAX!** 🚢

---

*Built with Python, Tweepy, python-telegram-bot, and 110+ professional tweet templates*
