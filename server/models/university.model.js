const { pool } = require("../config/connection.js");

async function getAllUniversity(){
    try {
        const result = await pool.query("SELECT * FROM public.universities");
        console.log('📊 Query result - rows found:', result.rows.length);
        return result.rows;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
}

async function getUniversityByName(universityName) {
    try {
        const result = await pool.query(
            "SELECT * FROM public.universities WHERE name = $1", 
            [universityName]
        );
        console.log('📊 University query result - rows found:', result.rows.length);
        return result.rows[0] || null;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
}

async function getCoursesByUniversity(universityName) {
    try {
        const result = await pool.query(
            "SELECT * FROM public.courses WHERE university = $1", 
            [universityName]
        );
        console.log('📊 Courses query result - rows found:', result.rows.length);
        return result.rows;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
}

async function getScholarshipsByUniversity(universityName) {
    try {
        const result = await pool.query(
            "SELECT * FROM public.scholarships WHERE university_name = $1", 
            [universityName]
        );
        console.log('📊 Scholarships query result - rows found:', result.rows.length);
        return result.rows;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
}

async function searchUniversities(query) {
    try {
        const result = await pool.query(
            "SELECT * FROM public.universities WHERE university ILIKE $1 OR country ILIKE $1", 
            [`%${query}%`]
        );
        console.log('📊 Search query result - rows found:', result.rows.length);
        return result.rows;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
}

module.exports = {
    getAllUniversity,
    getUniversityByName,
    getCoursesByUniversity,
    getScholarshipsByUniversity,
    searchUniversities
}