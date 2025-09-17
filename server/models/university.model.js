const { pool } = require("../config/connection.js");

async function getAllUniversity(){
    try {
        // Order by rank (ascending, so 1 comes before 2), then by name alphabetically
        const result = await pool.query(`
            SELECT * FROM public.universities 
            ORDER BY 
                CASE 
                    WHEN "Rank" IS NULL OR "Rank" = '' THEN 9999999 
                    ELSE CAST("Rank" AS INTEGER) 
                END ASC, 
                name ASC
        `);
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
        // Order search results by rank first, then by name
        const result = await pool.query(`
            SELECT * FROM public.universities 
            WHERE name ILIKE $1 OR country ILIKE $1
            ORDER BY 
                CASE 
                    WHEN "Rank" IS NULL OR "Rank" = '' THEN 9999999 
                    ELSE CAST("Rank" AS INTEGER) 
                END ASC, 
                name ASC
        `, [`%${query}%`]);
        console.log('📊 Search query result - rows found:', result.rows.length);
        return result.rows;
    } catch (error) {
        console.error('❌ DATABASE ERROR :', error.message);
        throw error;
    }
}

async function getUniversitiesByCountry(country) {
    try {
        // Get universities by exact country match, ordered by rank
        const result = await pool.query(`
            SELECT * FROM public.universities 
            WHERE country ILIKE $1
            ORDER BY 
                CASE 
                    WHEN "Rank" IS NULL OR "Rank" = '' THEN 9999999 
                    ELSE CAST("Rank" AS INTEGER) 
                END ASC, 
                name ASC
        `, [country]);
        console.log('📊 Universities by country query result - rows found:', result.rows.length);
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
    searchUniversities,
    getUniversitiesByCountry
}