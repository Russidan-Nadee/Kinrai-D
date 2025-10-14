# 🚀 Kinrai-D Deployment Guide

Complete guide for deploying Kinrai-D to Railway (Backend) and Netlify (Frontend).

---

## 📋 Prerequisites

- ✅ GitHub account
- ✅ Railway account (https://railway.app)
- ✅ Netlify account (https://netlify.com)
- ✅ Supabase database ready
- ✅ Code pushed to GitHub

---

## 🎯 Deployment Architecture

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   Netlify       │ ───> │   Railway       │ ───> │   Supabase      │
│  (Frontend)     │      │  (Backend API)  │      │  (Database)     │
│  Flutter Web    │      │  NestJS         │      │  PostgreSQL     │
└─────────────────┘      └─────────────────┘      └─────────────────┘
```

---

## 📦 Part 1: Deploy Backend to Railway

### Step 1: Push Code to GitHub

```bash
# Make sure all changes are committed
git add .
git commit -m "chore: add deployment configuration"
git push origin master
```

### Step 2: Create Railway Project

1. Go to https://railway.app
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose repository: `Kinrai-D`
5. Railway will detect:
   - ✅ Dockerfile
   - ✅ package.json

### Step 3: Configure Railway Settings

#### Set Root Directory:
```
Settings → Root Directory → backend
```

#### Set Environment Variables:
Go to **Variables** tab and add:

```bash
# Database
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.xjuqvzvfvmunmqhgaflr.supabase.co:5432/postgres

# Supabase
SUPABASE_URL=https://xjuqvzvfvmunmqhgaflr.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Environment
NODE_ENV=production

# CORS (update after getting Netlify URL)
CORS_ORIGINS=https://kinrai-d.netlify.app

# Logging
LOG_LEVEL=info
```

**Note:** Railway automatically sets `PORT` variable, don't add it manually.

### Step 4: Run Database Migration

After first deployment, run migration in Railway console:

```bash
# In Railway → Deployments → Click on deployment → Shell
npx prisma migrate deploy
```

### Step 5: Get Railway URL

After successful deployment, you'll get a URL like:
```
https://kinrai-d-backend-production-xxxx.up.railway.app
```

**Save this URL** - you'll need it for frontend configuration!

---

## 🌐 Part 2: Deploy Frontend to Netlify

### Step 1: Create Netlify Site

1. Go to https://netlify.com
2. Click **"Add new site"** → **"Import an existing project"**
3. Connect to GitHub
4. Choose repository: `Kinrai-D`

### Step 2: Configure Build Settings

Netlify will auto-detect `netlify.toml`, but verify:

```yaml
Base directory: frontend
Build command: flutter build web --release --web-renderer canvaskit
Publish directory: frontend/build/web
```

### Step 3: Set Environment Variables (Optional)

If you want to override API URL:

```bash
API_URL=https://your-railway-url.up.railway.app
```

**Note:** You can also hardcode Railway URL in `constants.dart` (line 11).

### Step 4: Update Frontend API URL

**Option A: Via Environment Variable** (Recommended)

Build with:
```bash
flutter build web --release --dart-define=API_URL=https://your-railway-url.up.railway.app
```

Add to Netlify build settings:
```toml
[build]
  command = "flutter build web --release --dart-define=API_URL=$API_URL"
```

**Option B: Hardcode in Code**

Edit `frontend/lib/core/utils/constants.dart`:
```dart
static const String _productionBaseUrl =
  'https://your-actual-railway-url.up.railway.app';  // Replace here
```

### Step 5: Get Netlify URL

After deployment, you'll get:
```
https://kinrai-d.netlify.app
```

or custom domain if configured.

### Step 6: Update Backend CORS

Go back to Railway → Variables and update:
```bash
CORS_ORIGINS=https://kinrai-d.netlify.app
```

Then redeploy backend.

---

## 🔄 Part 3: Final Updates

### Update Backend CORS

Edit `backend/src/main.ts` line 11:
```typescript
'https://kinrai-d.netlify.app',  // Your actual Netlify URL
```

### Update Frontend API URL

Edit `frontend/lib/core/utils/constants.dart` line 11:
```dart
defaultValue: 'https://your-railway-url.up.railway.app');  // Your actual Railway URL
```

### Commit and Push

```bash
git add .
git commit -m "chore: update production URLs"
git push origin master
```

Both Railway and Netlify will auto-deploy when you push to GitHub!

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] Backend health check: `https://your-railway-url.up.railway.app/api/v1`
- [ ] Frontend loads: `https://kinrai-d.netlify.app`
- [ ] Frontend can call backend APIs (check browser console)
- [ ] Database connection works (try login)
- [ ] No CORS errors in browser console
- [ ] Protein preferences working (test random menu)

---

## 🐛 Troubleshooting

### Backend Issues

**Build fails:**
```bash
# Check Railway logs
# Common issues:
# - Missing environment variables
# - Database connection failed
# - Prisma generate failed
```

**CORS errors:**
```bash
# Verify CORS_ORIGINS includes your Netlify URL
# Check browser console for exact origin
```

**Database connection fails:**
```bash
# Verify DATABASE_URL is correct
# Check Supabase firewall settings
# Ensure Prisma migration ran
```

### Frontend Issues

**Blank page:**
```bash
# Check browser console for errors
# Verify API_URL is correct
# Check Network tab for failed requests
```

**API calls fail:**
```bash
# Verify Railway URL is correct in constants.dart
# Check CORS settings on backend
# Verify backend is running
```

---

## 🔧 Environment Variables Quick Reference

### Railway (Backend)
| Variable | Example | Required |
|----------|---------|----------|
| DATABASE_URL | postgresql://... | ✅ Yes |
| SUPABASE_URL | https://xxx.supabase.co | ✅ Yes |
| SUPABASE_ANON_KEY | eyJ... | ✅ Yes |
| SUPABASE_SERVICE_ROLE_KEY | eyJ... | ✅ Yes |
| NODE_ENV | production | ✅ Yes |
| CORS_ORIGINS | https://kinrai-d.netlify.app | ✅ Yes |
| LOG_LEVEL | info | ❌ Optional |
| PORT | (auto-set by Railway) | ❌ Don't set |

### Netlify (Frontend)
| Variable | Example | Required |
|----------|---------|----------|
| API_URL | https://xxx.railway.app | ⚠️ Optional* |

*Optional if hardcoded in constants.dart

---

## 📝 Maintenance

### Update Backend Code
```bash
git push origin master
# Railway auto-deploys
```

### Update Frontend Code
```bash
git push origin master
# Netlify auto-deploys
```

### Run New Migrations
```bash
# In Railway Shell:
npx prisma migrate deploy
```

### View Logs
- Railway: Deployments → Click deployment → Logs
- Netlify: Deploys → Click deploy → Deploy log

---

## 🎉 You're Done!

Your app is now live on:
- **Frontend:** https://kinrai-d.netlify.app
- **Backend:** https://kinrai-d-backend-production.up.railway.app

---

## 💡 Tips

1. **Custom Domain:**
   - Netlify: Site settings → Domain management
   - Railway: Settings → Custom Domain

2. **Auto Deploy:**
   - Both platforms auto-deploy on `git push`
   - Disable in settings if you want manual control

3. **Preview Deploys:**
   - Netlify: Auto-creates preview for pull requests
   - Railway: Create preview environment from branches

4. **Rollback:**
   - Both platforms allow rollback to previous deployment
   - Railway: Deployments → Click previous → Restore
   - Netlify: Deploys → Click previous → Publish deploy

---

**Need help?** Check platform docs:
- Railway: https://docs.railway.app
- Netlify: https://docs.netlify.com
