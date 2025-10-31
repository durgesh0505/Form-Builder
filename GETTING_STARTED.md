# Getting Started with Rabbit Forms

This guide will help you set up Rabbit Forms locally and understand the project structure.

## Prerequisites

Before you begin, ensure you have:

- **Node.js 18+** installed ([Download](https://nodejs.org/))
- **npm**, **pnpm**, or **yarn** package manager
- **Git** installed
- **Supabase account** (free tier) - [Sign up](https://supabase.com/)
- **Code editor** (VS Code recommended)

## Step 1: Clone the Repository

```bash
git clone https://github.com/durgesh0505/Form-Builder.git
cd Form-Builder
```

## Step 2: Install Dependencies

Choose your preferred package manager:

```bash
# Using npm
npm install

# Using pnpm (recommended for faster installs)
pnpm install

# Using yarn
yarn install
```

## Step 3: Set Up Supabase

### 3.1 Create a Supabase Project

1. Go to [supabase.com](https://supabase.com/)
2. Click "New Project"
3. Fill in project details:
   - **Name**: rabbit-forms (or your choice)
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your location
4. Click "Create new project" (takes ~2 minutes)

### 3.2 Get Your Supabase Credentials

Once your project is ready:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key
   - **service_role** key (keep this secret!)

### 3.3 Run Database Migrations

You have two options:

#### Option A: Using Supabase Dashboard (Easier)

1. Go to **SQL Editor** in Supabase Dashboard
2. Click "New Query"
3. Copy the contents of `supabase/migrations/001_initial_schema.sql`
4. Paste and click "Run"
5. Repeat for `002_rls_policies.sql`

#### Option B: Using Supabase CLI (Recommended for development)

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

### 3.4 Create Storage Bucket for Signatures

1. Go to **Storage** in Supabase Dashboard
2. Click "New bucket"
3. Name: `signatures`
4. Public bucket: **Yes** (we need public URLs for signatures)
5. Click "Create bucket"

### 3.5 Set Up Storage Policies

In **Storage** → `signatures` bucket → **Policies**:

```sql
-- Allow public to insert signatures
CREATE POLICY "Public can upload signatures" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'signatures');

-- Allow public to read signatures
CREATE POLICY "Public can view signatures" ON storage.objects
  FOR SELECT USING (bucket_id = 'signatures');
```

## Step 4: Configure Environment Variables

1. Copy the example environment file:

```bash
cp .env.example .env.local
```

2. Edit `.env.local` and fill in your values:

```env
# Supabase (from Step 3.2)
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=Rabbit Forms

# Email (Optional for now - set up later)
# RESEND_API_KEY=re_xxxxxxxxxxxx
# RESEND_FROM_EMAIL=noreply@yourdomain.com

# CAPTCHA (Optional for now - set up later)
# NEXT_PUBLIC_TURNSTILE_SITE_KEY=
# TURNSTILE_SECRET_KEY=

# Encryption (Generate with: openssl rand -hex 32)
ENCRYPTION_KEY=your-32-byte-hex-key-here
```

### Generate Encryption Key

```bash
openssl rand -hex 32
```

Copy the output and paste it as `ENCRYPTION_KEY` in `.env.local`

## Step 5: Create Your Super Admin Account

### 5.1 Create Auth User in Supabase

1. Go to **Authentication** → **Users** in Supabase Dashboard
2. Click "Add user" → "Create new user"
3. Enter:
   - **Email**: your-email@example.com
   - **Password**: Choose a strong password
   - **Auto Confirm User**: Yes
4. Click "Create user"
5. **Copy the User ID** (UUID) - you'll need it!

### 5.2 Insert Super Admin Record

1. Go to **SQL Editor**
2. Run this query (replace `YOUR_USER_ID` and email):

```sql
INSERT INTO users (id, email, full_name, role)
VALUES (
  'YOUR_USER_ID',  -- UUID from Step 5.1
  'your-email@example.com',
  'Super Admin',
  'super_admin'
);
```

## Step 6: Run the Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser!

## Step 7: First Login

1. Navigate to `/login` (or click "Login" on homepage)
2. Enter the credentials from Step 5.1
3. You should be redirected to the Super Admin dashboard

## Next Steps

### Create Your First Business

1. From Super Admin Dashboard, click "Businesses"
2. Click "Create Business"
3. Fill in:
   - **Name**: My First Business
   - **Slug**: my-first-business (URL-safe)
4. Click "Create"

### Create a Business Admin

1. Click on your newly created business
2. Go to "Admins" tab
3. Click "Add Admin"
4. Enter admin email and password
5. The admin will receive login credentials

### Create Your First Form

1. Login as Business Admin
2. Click "Forms" → "New Form"
3. Drag fields onto the canvas
4. Configure settings
5. Click "Publish"

## Troubleshooting

### "Supabase client not initialized"

- Check that `.env.local` has correct `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- Restart the dev server after changing `.env.local`

### "Migration failed"

- Ensure you have the latest PostgreSQL version (Supabase uses 15+)
- Check for syntax errors in migration files
- Run migrations one at a time to identify issues

### "Authentication error"

- Verify user exists in **Authentication** → **Users**
- Check that user also exists in `users` table with correct `role`
- Ensure RLS policies are applied (run `002_rls_policies.sql`)

### "Permission denied" errors

- RLS policies may not be applied correctly
- Try running `002_rls_policies.sql` again
- Check that user's `role` matches expected value

## Development Tips

### Hot Reload

Next.js has hot reload enabled by default. Just save your files and changes will appear instantly.

### Database Changes

After modifying the database schema:

1. Create a new migration file in `supabase/migrations/`
2. Run it via SQL Editor or Supabase CLI
3. Restart dev server if needed

### Useful Commands

```bash
# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint

# Run tests (when implemented)
npm test
```

## Resources

- **[Implementation Plan](./RABBIT_FORMS_IMPLEMENTATION_PLAN.md)** - Full technical spec
- **[README](./README.md)** - Project overview
- **[Contributing](./CONTRIBUTING.md)** - How to contribute
- **[Supabase Docs](https://supabase.com/docs)** - Database and auth
- **[Next.js Docs](https://nextjs.org/docs)** - Framework documentation

## Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/durgesh0505/Form-Builder/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/durgesh0505/Form-Builder/discussions)

## What's Next?

Now that you have Rabbit Forms running locally, you can:

1. Explore the codebase (start with `src/app/`)
2. Read the [Implementation Plan](./RABBIT_FORMS_IMPLEMENTATION_PLAN.md)
3. Pick an issue to work on
4. Join the community discussions

Happy coding! 🐰
