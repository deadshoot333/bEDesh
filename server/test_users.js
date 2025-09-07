const { pool } = require("./config/connection");

async function getUsers() {
  try {
    const result = await pool.query('SELECT id, email, university FROM public.users LIMIT 5');
    console.log('\n=== DATABASE USERS ===');
    result.rows.forEach((user, index) => {
      console.log(`${index + 1}. ID: ${user.id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   University: ${user.university || 'Not set'}\n`);
    });
  } catch (error) {
    console.error('Error fetching users:', error);
  } finally {
    process.exit(0);
  }
}

getUsers();
