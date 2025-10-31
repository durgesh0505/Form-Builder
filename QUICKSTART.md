# Quick Start Guide ⚡

Get Rabbit Forms running in **5 minutes**! This is the fastest way to get started.

---

## Step 1: Get Supabase Credentials (2 minutes)

### 1. Open Your Supabase Project
Go to: [https://supabase.com/dashboard](https://supabase.com/dashboard)

### 2. Get Your Credentials
Click: **Settings** → **API**

You need these 3 values:

```
┌─────────────────────────────────────────────────┐
│ Project URL:                                    │
│ https://xxxxxxxxxxxxx.supabase.co              │
│                                                 │
│ anon public:                                    │
│ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey...     │
│                                                 │
│ service_role:                                   │
│ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey...     │
└─────────────────────────────────────────────────┘
```

**Keep this tab open** - you'll need these values!

---

## Step 2: Setup Database (1 minute)

### 1. Run Migrations
In Supabase Dashboard:
1. Click **SQL Editor** (left sidebar)
2. Click **New Query**
3. Open `supabase/migrations/001_initial_schema.sql` from your project
4. Copy all the SQL code
5. Paste into SQL Editor
6. Click **Run**

You should see: ✅ "Success. No rows returned"

### 2. Run RLS Policies
Repeat the same process for:
- `supabase/migrations/002_rls_policies.sql`

### 3. Create Storage Bucket
1. Click **Storage** (left sidebar)
2. Click **New bucket**
3. Name: `signatures`
4. Public: ✅ Yes
5. Click **Create bucket**

---

## Step 3: Local Environment Setup (2 minutes)

### 1. Generate Encryption Key

```bash
npm run generate-key
```

Copy the generated key (it will look like: `a1b2c3d4e5f6...`)

### 2. Create Environment File

```bash
cp .env.example .env.local
```

### 3. Edit `.env.local`

Open `.env.local` and replace these values:

```env
# Replace these 3 lines:
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# Paste your generated encryption key:
ENCRYPTION_KEY=paste_the_generated_key_here
```

### 4. Verify Setup

```bash
npm run check-env
```

You should see: ✅ "All environment variables are properly configured!"

---

## Step 4: Run the App! 🚀

```bash
npm run dev
```

Open: [http://localhost:3000](http://localhost:3000)

You should see the **Rabbit Forms** landing page! 🎉

---

## Step 5: Vercel Deployment (Optional)

Already deployed to `rabbitforms.vercel.app`? Add environment variables:

### 1. Open Vercel Project
Go to: [https://vercel.com/dashboard](https://vercel.com/dashboard)

### 2. Add Environment Variables
Click: **Settings** → **Environment Variables**

Add these 4 variables (click "Add New" for each):

| Key | Value | Environments |
|-----|-------|--------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Your Project URL | ✅ All |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Your anon key | ✅ All |
| `SUPABASE_SERVICE_ROLE_KEY` | Your service_role key | ✅ All |
| `ENCRYPTION_KEY` | Your generated key | ✅ All |

For "All" - check: Production, Preview, Development

### 3. Redeploy
1. Go to **Deployments** tab
2. Click **⋯** on latest deployment
3. Click **Redeploy**

Wait ~1 minute, then visit: `https://rabbitforms.vercel.app`

---

## ✅ You're Done!

**What's working:**
- ✅ Next.js app running
- ✅ Supabase connected
- ✅ Database tables created
- ✅ Environment variables configured

**What's next:**
- 📖 Read [GETTING_STARTED.md](./GETTING_STARTED.md) for detailed setup
- 🔧 Create your first Super Admin account
- 🎨 Start building features

---

## 🚨 Troubleshooting

### "npm run check-env" fails
- Make sure you copied the values correctly from Supabase
- Check for extra spaces in `.env.local`
- Make sure encryption key is 64 characters long

### "Supabase connection error"
- Verify your Project URL format: `https://xxxxx.supabase.co`
- Check that migrations ran successfully
- Try restarting: `npm run dev`

### "Vercel deployment fails"
- Make sure all 4 environment variables are added
- Check "All" environments when adding variables
- Try redeploying with "Clear Build Cache"

---

## 📚 More Help

- **Full Setup Guide**: [ENV_SETUP_GUIDE.md](./ENV_SETUP_GUIDE.md)
- **Getting Started**: [GETTING_STARTED.md](./GETTING_STARTED.md)
- **Implementation Plan**: [RABBIT_FORMS_IMPLEMENTATION_PLAN.md](./RABBIT_FORMS_IMPLEMENTATION_PLAN.md)

---

**Need help?** Open an issue on [GitHub](https://github.com/durgesh0505/Form-Builder/issues)

Happy building! 🐰
