require('dotenv').config();

console.log('🔍 ENVIRONMENT VARIABLES CHECK:');
console.log('=====================================');
console.log('SUPABASE_DB_URL:', process.env.SUPABASE_DB_URL ? '✅ SET' : '❌ NOT SET');
console.log('SUPABASE_URL:', process.env.SUPABASE_URL ? '✅ SET' : '❌ NOT SET');
console.log('SUPABASE_KEY:', process.env.SUPABASE_KEY ? '✅ SET' : '❌ NOT SET');
console.log('JWT_SECRET:', process.env.JWT_SECRET ? '✅ SET' : '❌ NOT SET');
console.log('JWT_ACCESS_EXPIRES_IN:', process.env.JWT_ACCESS_EXPIRES_IN || '⚠️  NOT SET (using default: 15m)');
console.log('JWT_REFRESH_EXPIRES_IN:', process.env.JWT_REFRESH_EXPIRES_IN || '⚠️  NOT SET (using default: 7d)');

// Test database connection
if (process.env.SUPABASE_DB_URL) {
  console.log('\n🗄️  TESTING DATABASE CONNECTION:');
  console.log('=====================================');
  
  const { Pool } = require('pg');
  const pool = new Pool({
    connectionString: process.env.SUPABASE_DB_URL,
    ssl: { rejectUnauthorized: false },
  });

  pool.connect((err, client, release) => {
    if (err) {
      console.log('❌ Database connection failed:', err.message);
    } else {
      console.log('✅ Database connected successfully');
      
      // Test if users table exists
      client.query("SELECT table_name FROM information_schema.tables WHERE table_name = 'users'", (err, result) => {
        if (err) {
          console.log('❌ Error checking users table:', err.message);
        } else if (result.rows.length > 0) {
          console.log('✅ Users table exists');
          
          // Check table structure
          client.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users'", (err, result) => {
            if (err) {
              console.log('❌ Error checking table structure:', err.message);
            } else {
              console.log('📋 Users table structure:');
              result.rows.forEach(row => {
                console.log(`  - ${row.column_name}: ${row.data_type}`);
              });
            }
            release();
            pool.end();
          });
        } else {
          console.log('❌ Users table does not exist');
          release();
          pool.end();
        }
      });
    }
  });
} else {
  console.log('\n❌ Cannot test database - SUPABASE_DB_URL not set');
}
