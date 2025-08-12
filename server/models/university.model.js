const { pool } = require("../config/connection.js");

async function getAllUniversity(){
    try {
    const result = await pool.query("SELECT * FROM public.universities");
    console.log('📊 Query result - rows found:', result.rows.length);
    return result.rows[0];
  } catch (error) {
    console.error('❌ DATABASE ERROR :', error.message);
    throw error;
  }
}

module.exports = {
    getAllUniversity
}