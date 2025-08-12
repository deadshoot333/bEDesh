const { pool } = require("./config/connection.js");

async function insertTestData() {
    try {
        console.log('🌱 Inserting test university data...');
        
        // First, let's check what tables and columns exist
        const tablesQuery = `
            SELECT table_name, column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name IN ('universities', 'courses', 'scholarships')
            ORDER BY table_name, ordinal_position;
        `;
        
        const result = await pool.query(tablesQuery);
        console.log('📊 Available tables and columns:');
        console.log(result.rows);
        
        // Try to get existing data to see structure
        try {
            const universitiesResult = await pool.query("SELECT * FROM public.universities LIMIT 1");
            console.log('🏫 Sample university record:', universitiesResult.rows[0]);
        } catch (e) {
            console.log('⚠️ No data in universities table yet');
        }
        
        try {
            const coursesResult = await pool.query("SELECT * FROM public.courses LIMIT 1");
            console.log('📚 Sample course record:', coursesResult.rows[0]);
        } catch (e) {
            console.log('⚠️ No data in courses table yet');
        }
        
        try {
            const scholarshipsResult = await pool.query("SELECT * FROM public.scholarships LIMIT 1");
            console.log('🎓 Sample scholarship record:', scholarshipsResult.rows[0]);
        } catch (e) {
            console.log('⚠️ No data in scholarships table yet');
        }
        
        console.log('🎉 Database structure analysis complete!');
        
    } catch (error) {
        console.error('❌ Error analyzing database:', error.message);
    } finally {
        process.exit(0);
    }
}

// Run the analysis
insertTestData();
