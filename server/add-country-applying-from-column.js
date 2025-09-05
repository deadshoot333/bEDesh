require('dotenv').config();

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.SUPABASE_DB_URL,
  ssl: { rejectUnauthorized: false },
});

async function addCountryApplyingFromColumn() {
  console.log('🔧 Adding country_applying_from column to users table...');
  
  try {
    // First check if column already exists
    const checkColumn = await pool.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'users' AND column_name = 'country_applying_from'
    `);
    
    if (checkColumn.rows.length > 0) {
      console.log('✅ Column country_applying_from already exists');
      return;
    }
    
    // Add the column
    const result = await pool.query(`
      ALTER TABLE public.users 
      ADD COLUMN country_applying_from TEXT
    `);
    
    console.log('✅ Successfully added country_applying_from column');
    
  } catch (error) {
    console.error('❌ Error adding column:', error.message);
    throw error;
  } finally {
    await pool.end();
  }
}

addCountryApplyingFromColumn()
  .then(() => {
    console.log('🎉 Migration completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Migration failed:', error);
    process.exit(1);
  });
