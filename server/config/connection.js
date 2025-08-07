const { createClient } = require("@supabase/supabase-js");
const { Pool } = require("pg");

// Load environment variables from the correct path
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });

console.log('🔧 Environment variables loaded');

const SUPABASE_DB_URL = process.env.SUPABASE_DB_URL
const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_KEY = process.env.SUPABASE_KEY

console.log('🔍 Checking environment variables...');

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error("Missing Supabase credentials. Check your .env file.");
  process.exit(1);
}

if (!SUPABASE_DB_URL) {
  console.error("Missing SUPABASE_DB_URL. Check your .env file.");
  process.exit(1);
}

console.log('✅ Environment variables validated');

// Create pool lazily to avoid hanging during module load
let pool = null;
let supabase = null;

function getPool() {
  if (!pool) {
    console.log('🔗 Creating database pool...');
    pool = new Pool({
      connectionString: SUPABASE_DB_URL,
      ssl: { rejectUnauthorized: false },
    });

    pool.on('connect', () => {
      console.log('Database connected successfully');
    });

    pool.on('error', (err) => {
      console.error('Database connection error:', err);
    });
  }
  return pool;
}

function getSupabase() {
  if (!supabase) {
    console.log('🔗 Creating Supabase client...');
    supabase = createClient(SUPABASE_URL, SUPABASE_KEY);
  }
  return supabase;
}

console.log('✅ Connection module initialized');

module.exports = {
  get supabase() {
    return getSupabase();
  },
  get pool() {
    return getPool();
  }
};
