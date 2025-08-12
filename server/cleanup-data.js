const { pool } = require("./config/connection.js");

async function cleanupTestData() {
    try {
        console.log('🧹 Cleaning up test data...');
        
        // First, let's see what the original data looks like
        console.log('\n📊 Current data before cleanup:');
        
        const currentCourses = await pool.query(
            "SELECT * FROM public.courses WHERE university = $1", 
            ['Oxford University']
        );
        console.log(`Current courses: ${currentCourses.rows.length}`);
        
        const currentScholarships = await pool.query(
            "SELECT * FROM public.scholarships WHERE university_name = $1", 
            ['Oxford University']
        );
        console.log(`Current scholarships: ${currentScholarships.rows.length}`);
        
        // Let's keep only the first course and first scholarship (presumably your original data)
        console.log('\n🎯 Keeping only the first course and first scholarship...');
        
        // Delete all courses except the first one
        const firstCourse = currentCourses.rows[0];
        await pool.query(
            "DELETE FROM public.courses WHERE university = $1 AND id != $2", 
            ['Oxford University', firstCourse.id]
        );
        
        // Delete all scholarships except the first one
        const firstScholarship = currentScholarships.rows[0];
        await pool.query(
            "DELETE FROM public.scholarships WHERE university_name = $1 AND name != $2", 
            ['Oxford University', firstScholarship.name]
        );
        
        // Verify cleanup
        const finalCourses = await pool.query(
            "SELECT COUNT(*) as count FROM public.courses WHERE university = $1", 
            ['Oxford University']
        );
        
        const finalScholarships = await pool.query(
            "SELECT COUNT(*) as count FROM public.scholarships WHERE university_name = $1", 
            ['Oxford University']
        );
        
        console.log(`\n✅ Cleanup complete!`);
        console.log(`📚 Remaining courses: ${finalCourses.rows[0].count}`);
        console.log(`🎓 Remaining scholarships: ${finalScholarships.rows[0].count}`);
        
        // Show what's left
        const remainingCourse = await pool.query(
            "SELECT name, level, field_of_study FROM public.courses WHERE university = $1", 
            ['Oxford University']
        );
        
        const remainingScholarship = await pool.query(
            "SELECT name, type, weightage FROM public.scholarships WHERE university_name = $1", 
            ['Oxford University']
        );
        
        console.log('\n📋 Remaining data:');
        console.log(`Course: ${remainingCourse.rows[0].name} (${remainingCourse.rows[0].level})`);
        console.log(`Scholarship: ${remainingScholarship.rows[0].name} (${remainingScholarship.rows[0].type})`);
        
    } catch (error) {
        console.error('❌ Error cleaning up data:', error.message);
    } finally {
        process.exit(0);
    }
}

cleanupTestData();
