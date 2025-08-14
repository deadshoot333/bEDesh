const { pool } = require("../config/connection.js");

async function getAllCountry() {
    try {
        const result = await pool.query("SELECT * FROM public.countries");
        console.log('📊 Query result - rows found:', result.rows.length);
        return result.rows;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
    
}

module.exports = {
    getAllCountry
}