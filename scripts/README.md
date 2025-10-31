# Scripts

Helper scripts for setting up and managing Rabbit Forms.

## Available Scripts

### 🔐 `generate-encryption-key.js`

Generates a secure 32-byte encryption key for storing API keys and sensitive data.

**Usage:**
```bash
npm run generate-key
# or
node scripts/generate-encryption-key.js
```

**Output:**
```
🔐 Generating encryption key for Rabbit Forms...

Your encryption key:
──────────────────────────────────────────────────────────────────────
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
──────────────────────────────────────────────────────────────────────

📋 Copy this key and add it to your .env.local file:

ENCRYPTION_KEY=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2

⚠️  Keep this key secure and never commit it to git!
```

Copy the generated key and add it to your `.env.local` file.

---

### ✅ `check-env.js`

Validates that all required environment variables are properly configured.

**Usage:**
```bash
npm run check-env
# or
node scripts/check-env.js
```

**What it checks:**
- ✅ `.env.local` file exists
- ✅ Required variables are set (not empty or placeholder)
- ✅ Supabase URL format is correct
- ✅ Encryption key length is sufficient
- ✅ `.env.local` is in `.gitignore`
- ⚪ Optional variables (warnings only)

**Example output:**
```
🔍 Checking environment variables for Rabbit Forms...

📋 Required Variables:

   ✅ NEXT_PUBLIC_SUPABASE_URL: OK
   ✅ NEXT_PUBLIC_SUPABASE_ANON_KEY: OK (237 chars)
   ✅ SUPABASE_SERVICE_ROLE_KEY: OK (237 chars)
   ✅ ENCRYPTION_KEY: OK (64 chars)

📋 Optional Variables:

   ✅ NEXT_PUBLIC_APP_URL: http://localhost:3000
   ✅ NEXT_PUBLIC_APP_NAME: Rabbit Forms
   ⚪ RESEND_API_KEY: Not set (optional)
   ⚪ RESEND_FROM_EMAIL: Not set (optional)

🔒 Security Checks:

   ✅ ENCRYPTION_KEY length: OK
   ✅ .env.local is in .gitignore
   ℹ️  APP_URL is set to localhost (OK for development)

==================================================

✅ All environment variables are properly configured!
   You can now run: npm run dev
```

**Exit codes:**
- `0` - All checks passed
- `1` - Required variables missing or invalid

---

## Quick Setup Workflow

Follow this sequence for first-time setup:

```bash
# 1. Generate encryption key
npm run generate-key

# 2. Copy .env.example to .env.local
cp .env.example .env.local

# 3. Edit .env.local with your values
#    - Add Supabase credentials
#    - Paste generated encryption key

# 4. Verify everything is correct
npm run check-env

# 5. Start development server
npm run dev
```

---

## Adding New Scripts

When adding new scripts to this directory:

1. Make the script executable:
   ```bash
   chmod +x scripts/your-script.js
   ```

2. Add shebang at the top:
   ```javascript
   #!/usr/bin/env node
   ```

3. Add npm script to `package.json`:
   ```json
   {
     "scripts": {
       "your-command": "node scripts/your-script.js"
     }
   }
   ```

4. Document it in this README

---

## Troubleshooting

### "Permission denied" error

Make scripts executable:
```bash
chmod +x scripts/*.js
```

### "Module not found" error

Make sure you're running scripts from the project root:
```bash
cd /path/to/Form-Builder
npm run check-env
```

### Scripts not found in npm

Reinstall dependencies:
```bash
npm install
```

---

For more help, see:
- [QUICKSTART.md](../QUICKSTART.md) - Quick setup guide
- [ENV_SETUP_GUIDE.md](../ENV_SETUP_GUIDE.md) - Detailed environment setup
- [GETTING_STARTED.md](../GETTING_STARTED.md) - Full getting started guide
