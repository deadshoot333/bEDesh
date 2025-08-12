const { pool } = require("./config/connection.js");

async function checkDatabaseData() {
    try {
        console.log('🔍 Checking database data...');
        
        // Check courses for Oxford University
        const coursesResult = await pool.query(
            "SELECT COUNT(*) as count FROM public.courses WHERE university = $1", 
            ['Oxford University']
        );
        console.log(`📚 Total Courses for Oxford University: ${coursesResult.rows[0].count}`);
        
        // List all courses
        const allCoursesResult = await pool.query(
            "SELECT name, level, field_of_study FROM public.courses WHERE university = $1", 
            ['Oxford University']
        );
        console.log('📚 Course List:');
        allCoursesResult.rows.forEach((course, index) => {
            console.log(`  ${index + 1}. ${course.name} (${course.level}) - ${course.field_of_study}`);
        });
        
        // Check scholarships for Oxford University
        const scholarshipsResult = await pool.query(
            "SELECT COUNT(*) as count FROM public.scholarships WHERE university_name = $1", 
            ['Oxford University']
        );
        console.log(`\n🎓 Total Scholarships for Oxford University: ${scholarshipsResult.rows[0].count}`);
        
        // List all scholarships
        const allScholarshipsResult = await pool.query(
            "SELECT name, type, weightage FROM public.scholarships WHERE university_name = $1", 
            ['Oxford University']
        );
        console.log('🎓 Scholarship List:');
        allScholarshipsResult.rows.forEach((scholarship, index) => {
            console.log(`  ${index + 1}. ${scholarship.name} (${scholarship.type}) - ${scholarship.weightage}`);
        });
        
    } catch (error) {
        console.error('❌ Error checking database:', error.message);
    } finally {
        process.exit(0);
    }
}

checkDatabaseData();
