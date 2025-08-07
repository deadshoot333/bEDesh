const { createClient } = require("@supabase/supabase-js");
const { Pool } = require("pg");


const SUPABASE_DB_URL = process.env.SUPBASE_DB_URL
const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_KEY = process.env.SUPABASE_KEY

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error("Missing Supabase credentials. Check your .env file.");
  process.exit(1);
}

const supabase = createClient(
  SUPABASE_URL,
  SUPABASE_KEY
);

const pool = new Pool({
  connectionString: SUPABASE_DB_URL,
  ssl: { rejectUnauthorized: false },
});
module.exports = {supabase, pool};
