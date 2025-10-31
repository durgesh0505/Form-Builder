#!/usr/bin/env node

/**
 * Encryption Key Generator
 * Generates a secure 32-byte hex string for ENCRYPTION_KEY
 *
 * Usage: node scripts/generate-encryption-key.js
 */

const crypto = require('crypto');

console.log('🔐 Generating encryption key for Rabbit Forms...\n');

// Generate 32 random bytes and convert to hex string
const encryptionKey = crypto.randomBytes(32).toString('hex');

console.log('Your encryption key:');
console.log('─'.repeat(70));
console.log(encryptionKey);
console.log('─'.repeat(70));
console.log('\n📋 Copy this key and add it to your .env.local file:');
console.log(`\nENCRYPTION_KEY=${encryptionKey}\n`);
console.log('⚠️  Keep this key secure and never commit it to git!\n');
