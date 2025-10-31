# Environment Variables Setup Guide

This guide will walk you through setting up environment variables for **Rabbit Forms** both locally and on Vercel.

---

## 📋 Prerequisites

Before you begin, make sure you have:
- ✅ Created a Supabase project
- ✅ Linked your GitHub repo to Vercel
- ✅ Cloned the repository locally

---

## Part 1: Get Your Supabase Credentials

### Step 1: Navigate to Your Supabase Project

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Click on your **Rabbit Forms** project

### Step 2: Get Project URL and API Keys

1. In the left sidebar, click **⚙️ Settings** → **API**
2. You'll see three important values:

   **📍 Project URL**
   ```
   Example: https://abcdefghijklmnop.supabase.co
   ```

   **🔑 API Keys**
   - **anon public** (safe to use in browser)
   - **service_role** (⚠️ KEEP SECRET - never expose in frontend)

3. **Copy these values** - you'll need them in a moment!

### Step 3: Verify Your Database

Before proceeding, make sure you've run the database migrations:

1. Go to **SQL Editor** in Supabase
2. Click **New Query**
3. Copy and paste the contents of `supabase/migrations/001_initial_schema.sql`
4. Click **Run**
5. Repeat for `supabase/migrations/002_rls_policies.sql`

You should see: "Success. No rows returned"

### Step 4: Create Storage Bucket

1. Go to **Storage** in the left sidebar
2. Click **New bucket**
3. Enter these details:
   - **Name**: `signatures`
   - **Public bucket**: ✅ Yes (checked)
   - **File size limit**: 2 MB
4. Click **Create bucket**

---

## Part 2: Local Environment Setup

### Step 1: Create `.env.local` File

In your project root directory, run:

```bash
cd /path/to/Form-Builder
cp .env.example .env.local
```

### Step 2: Generate Encryption Key

You need a secure encryption key for API key storage. Run this command:

```bash
openssl rand -hex 32
```

**Copy the output** (it will look like: `a1b2c3d4e5f6...`)

### Step 3: Edit `.env.local`

Open `.env.local` in your code editor and fill in the values:

```env
# ======================
# Supabase Configuration
# ======================
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ======================
# App Configuration
# ======================
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=Rabbit Forms
NEXT_PUBLIC_APP_DESCRIPTION=Complete Form Builder SaaS Solution

# ======================
# Security & Encryption
# ======================
ENCRYPTION_KEY=paste_your_generated_key_here

# ======================
# Email Configuration (Optional - for later)
# ======================
# RESEND_API_KEY=
# RESEND_FROM_EMAIL=noreply@rabbitforms.com

# ======================
# CAPTCHA Configuration (Optional - for later)
# ======================
# NEXT_PUBLIC_TURNSTILE_SITE_KEY=
# TURNSTILE_SECRET_KEY=

# ======================
# Development Settings
# ======================
NODE_ENV=development
```

### Step 4: Replace the Placeholders

Replace these values:
- `YOUR_PROJECT_ID` → Your actual Supabase Project ID (from Step 2)
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` → Your anon key (from Step 2)
- `SUPABASE_SERVICE_ROLE_KEY` → Your service_role key (from Step 2)
- `ENCRYPTION_KEY` → The key you generated in Step 2

### Step 5: Save and Test

1. **Save** the `.env.local` file
2. **Restart** your development server if it's running:

```bash
npm run dev
```

3. Open [http://localhost:3000](http://localhost:3000)

You should see the landing page without any errors!

---

## Part 3: Vercel Environment Setup

### Step 1: Open Vercel Dashboard

1. Go to [https://vercel.com/dashboard](https://vercel.com/dashboard)
2. Click on your **Rabbit Forms** project

### Step 2: Navigate to Environment Variables

1. Click **Settings** tab (top menu)
2. Click **Environment Variables** (left sidebar)

### Step 3: Add Environment Variables

Click **Add New** and add each variable one by one:

#### Required Variables (Add these now)

| Key | Value | Environment |
|-----|-------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://YOUR_PROJECT.supabase.co` | Production, Preview, Development |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Your anon key from Supabase | Production, Preview, Development |
| `SUPABASE_SERVICE_ROLE_KEY` | Your service_role key from Supabase | Production, Preview, Development |
| `NEXT_PUBLIC_APP_URL` | `https://rabbitforms.vercel.app` | Production |
| `NEXT_PUBLIC_APP_URL` | `http://localhost:3000` | Development |
| `NEXT_PUBLIC_APP_NAME` | `Rabbit Forms` | Production, Preview, Development |
| `ENCRYPTION_KEY` | Your generated encryption key | Production, Preview, Development |

**For each variable:**
1. Enter the **Key** (left field)
2. Enter the **Value** (right field)
3. Select environments:
   - ✅ Production (for rabbitforms.vercel.app)
   - ✅ Preview (for PR preview deployments)
   - ✅ Development (for local development)
4. Click **Save**

#### Optional Variables (Add later when needed)

You can add these later when you set up email and CAPTCHA:

```
RESEND_API_KEY
RESEND_FROM_EMAIL
NEXT_PUBLIC_TURNSTILE_SITE_KEY
TURNSTILE_SECRET_KEY
```

### Step 4: Redeploy

After adding all environment variables:

1. Go to **Deployments** tab
2. Click the **⋯** (three dots) on the latest deployment
3. Click **Redeploy**
4. Check **Use existing Build Cache** ✅
5. Click **Redeploy**

Wait 1-2 minutes for deployment to complete.

### Step 5: Verify Deployment

1. Click **Visit** button to open your site
2. Go to `https://rabbitforms.vercel.app`
3. You should see the landing page!

---

## Part 4: Verification Checklist

### Local Development ✓

Run these checks locally:

```bash
# 1. Check environment variables are loaded
npm run dev
```

Open browser console (F12) and type:
```javascript
console.log(process.env.NEXT_PUBLIC_SUPABASE_URL)
```

You should see your Supabase URL (not `undefined`).

### Vercel Production ✓

1. Visit `https://rabbitforms.vercel.app`
2. Open browser console (F12)
3. Type:
   ```javascript
   console.log(window.location.href)
   ```
4. Check for any console errors

No errors = ✅ Success!

---

## 🔒 Security Best Practices

### ⚠️ NEVER expose these in frontend code:
- ❌ `SUPABASE_SERVICE_ROLE_KEY`
- ❌ `ENCRYPTION_KEY`
- ❌ Any API secret keys

### ✅ Safe to use in frontend (with `NEXT_PUBLIC_` prefix):
- ✅ `NEXT_PUBLIC_SUPABASE_URL`
- ✅ `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- ✅ `NEXT_PUBLIC_APP_URL`

### 🛡️ Additional Security:
- Never commit `.env.local` to git (already in `.gitignore`)
- Rotate your `service_role` key if accidentally exposed
- Use different Supabase projects for dev/staging/production

---

## 🚨 Troubleshooting

### Issue: "Supabase client error"

**Solution:**
1. Check that all `NEXT_PUBLIC_SUPABASE_*` variables are set
2. Verify the URL format: `https://xxxxx.supabase.co` (no trailing slash)
3. Restart dev server: `npm run dev`

### Issue: "Authentication not working"

**Solution:**
1. Check that migrations have been run in Supabase
2. Verify RLS policies are enabled
3. Check `SUPABASE_SERVICE_ROLE_KEY` is correct

### Issue: "Vercel build fails"

**Solution:**
1. Check all environment variables are added in Vercel
2. Make sure keys have no extra spaces
3. Redeploy with "Clear Build Cache"

### Issue: "Environment variables not updating"

**Local:**
```bash
# Stop the server (Ctrl+C)
rm -rf .next
npm run dev
```

**Vercel:**
1. Update the variable in Settings
2. Trigger a new deployment

---

## 📝 Quick Reference

### Get Supabase Credentials
```
Supabase Dashboard → Settings → API
- Project URL
- anon public key
- service_role key (secret!)
```

### Generate Encryption Key
```bash
openssl rand -hex 32
```

### Local Environment File
```
.env.local (in project root)
```

### Vercel Environment Variables
```
Vercel Dashboard → Project → Settings → Environment Variables
```

---

## ✅ You're All Set!

Once you've completed all steps above, you're ready to start developing!

**Next steps:**
1. ✅ Environment variables configured
2. 🚀 Run migrations in Supabase
3. 🎨 Start building features

Need help? Check [GETTING_STARTED.md](./GETTING_STARTED.md) or open an issue on GitHub!
