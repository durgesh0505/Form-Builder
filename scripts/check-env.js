#!/usr/bin/env node

/**
 * Environment Variables Validation Script
 * Run this to check if your environment variables are properly configured
 *
 * Usage: node scripts/check-env.js
 */

const fs = require('fs');
const path = require('path');

console.log('🔍 Checking environment variables for Rabbit Forms...\n');

// Required environment variables
const requiredVars = [
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
  'ENCRYPTION_KEY',
];

// Optional environment variables
const optionalVars = [
  'NEXT_PUBLIC_APP_URL',
  'NEXT_PUBLIC_APP_NAME',
  'RESEND_API_KEY',
  'RESEND_FROM_EMAIL',
  'NEXT_PUBLIC_TURNSTILE_SITE_KEY',
  'TURNSTILE_SECRET_KEY',
];

let hasErrors = false;
let warnings = 0;

// Load environment variables from .env.local
const envPath = path.join(process.cwd(), '.env.local');

if (!fs.existsSync(envPath)) {
  console.error('❌ ERROR: .env.local file not found!');
  console.log('   Create it by running: cp .env.example .env.local\n');
  process.exit(1);
}

// Parse .env.local file
const envContent = fs.readFileSync(envPath, 'utf8');
const envVars = {};

envContent.split('\n').forEach(line => {
  const trimmed = line.trim();
  if (trimmed && !trimmed.startsWith('#')) {
    const [key, ...valueParts] = trimmed.split('=');
    if (key) {
      envVars[key.trim()] = valueParts.join('=').trim();
    }
  }
});

console.log('📋 Required Variables:\n');

// Check required variables
requiredVars.forEach(varName => {
  const value = envVars[varName];

  if (!value || value === '' || value.includes('your-') || value.includes('YOUR_')) {
    console.log(`   ❌ ${varName}: MISSING or uses placeholder`);
    hasErrors = true;
  } else {
    // Validate format
    if (varName === 'NEXT_PUBLIC_SUPABASE_URL') {
      if (!value.startsWith('https://') || !value.includes('.supabase.co')) {
        console.log(`   ⚠️  ${varName}: Invalid format (should be https://xxxxx.supabase.co)`);
        hasErrors = true;
      } else {
        console.log(`   ✅ ${varName}: OK`);
      }
    } else if (varName.includes('KEY')) {
      const previewLength = Math.min(value.length, 20);
      const preview = value.substring(0, previewLength) + '...';
      console.log(`   ✅ ${varName}: OK (${value.length} chars)`);
    } else {
      console.log(`   ✅ ${varName}: ${value}`);
    }
  }
});

console.log('\n📋 Optional Variables:\n');

// Check optional variables
optionalVars.forEach(varName => {
  const value = envVars[varName];

  if (!value || value === '') {
    console.log(`   ⚪ ${varName}: Not set (optional)`);
    warnings++;
  } else if (value.includes('your-') || value.includes('YOUR_')) {
    console.log(`   ⚪ ${varName}: Uses placeholder (optional)`);
    warnings++;
  } else {
    console.log(`   ✅ ${varName}: ${value}`);
  }
});

// Security checks
console.log('\n🔒 Security Checks:\n');

// Check ENCRYPTION_KEY length
const encryptionKey = envVars['ENCRYPTION_KEY'];
if (encryptionKey && encryptionKey.length < 32) {
  console.log('   ⚠️  ENCRYPTION_KEY is too short (should be 64 hex chars)');
  hasErrors = true;
} else if (encryptionKey && encryptionKey.length >= 64) {
  console.log('   ✅ ENCRYPTION_KEY length: OK');
} else {
  console.log('   ❌ ENCRYPTION_KEY: MISSING');
}

// Check if .env.local is in .gitignore
const gitignorePath = path.join(process.cwd(), '.gitignore');
if (fs.existsSync(gitignorePath)) {
  const gitignoreContent = fs.readFileSync(gitignorePath, 'utf8');
  if (gitignoreContent.includes('.env') || gitignoreContent.includes('.env.local')) {
    console.log('   ✅ .env.local is in .gitignore');
  } else {
    console.log('   ⚠️  .env.local might not be in .gitignore!');
    warnings++;
  }
}

// Check APP_URL for production
const appUrl = envVars['NEXT_PUBLIC_APP_URL'];
if (appUrl && appUrl.includes('localhost')) {
  console.log('   ℹ️  APP_URL is set to localhost (OK for development)');
} else if (appUrl && appUrl.includes('vercel.app')) {
  console.log('   ✅ APP_URL is set for production');
}

// Summary
console.log('\n' + '='.repeat(50));
if (hasErrors) {
  console.log('\n❌ Environment check FAILED!');
  console.log('   Please fix the errors above before running the app.\n');
  console.log('   See ENV_SETUP_GUIDE.md for detailed instructions.\n');
  process.exit(1);
} else if (warnings > 0) {
  console.log('\n⚠️  Environment check passed with warnings');
  console.log(`   ${warnings} optional variable(s) not set.`);
  console.log('   You can run the app, but some features may not work.\n');
  process.exit(0);
} else {
  console.log('\n✅ All environment variables are properly configured!');
  console.log('   You can now run: npm run dev\n');
  process.exit(0);
}
