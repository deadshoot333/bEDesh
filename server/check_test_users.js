const { pool } = require("./config/connection");

async function checkTestUsers() {
  try {
    const result = await pool.query(
      "SELECT id, email FROM public.users WHERE email = $1 OR email = $2", 
      ['mausin@gmail.com', 'ayaan@test.com']
    );
    
    console.log('\n=== TEST USERS ===');
    if (result.rows.length === 0) {
      console.log('No test users found!');
    } else {
      result.rows.forEach((user, index) => {
        console.log(`${index + 1}. ID: ${user.id}`);
        console.log(`   Email: ${user.email}\n`);
      });
    }
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    process.exit(0);
  }
}

checkTestUsers();
