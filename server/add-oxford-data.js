const { pool } = require("./config/connection.js");

async function addOxfordData() {
    try {
        console.log('📚 Adding course and scholarship data for Oxford University...');
        
        // Add some courses for Oxford University
        const coursesQuery = `
            INSERT INTO public.courses (id, level, field_of_study, duration, intake, annual_fee, name, university, url)
            VALUES 
                (gen_random_uuid(), 'Undergraduate', 'Computer Science', '3 years', 'September', '£9,250', 'BSc Computer Science', 'Oxford University', 'https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/computer-science'),
                (gen_random_uuid(), 'Postgraduate', 'Medicine', '6 years', 'October', '£37,510', 'Doctor of Medicine', 'Oxford University', 'https://www.ox.ac.uk/admissions/graduate'),
                (gen_random_uuid(), 'Masters', 'Engineering Science', '4 years', 'September', '£32,760', 'MEng Engineering Science', 'Oxford University', 'https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/engineering-science'),
                (gen_random_uuid(), 'Undergraduate', 'Mathematics', '3 years', 'September', '£9,250', 'BA Mathematics', 'Oxford University', 'https://www.ox.ac.uk/admissions/undergraduate/courses/course-listing/mathematics'),
                (gen_random_uuid(), 'Masters', 'Philosophy', '2 years', 'September', '£28,040', 'MPhil Philosophy', 'Oxford University', 'https://www.ox.ac.uk/admissions/graduate')
            ON CONFLICT (id) DO NOTHING;
        `;
        
        await pool.query(coursesQuery);
        console.log('✅ Courses added successfully');
        
        // Add some scholarships for Oxford University
        const scholarshipsQuery = `
            INSERT INTO public.scholarships (name, university_name, type, weightage, degree_type)
            VALUES 
                ('Rhodes Scholarship', 'Oxford University', 'International', 'Full Funding', 'Masters'),
                ('Oxford Excellence Scholarship', 'Oxford University', 'Merit', 'Partial Funding', 'Undergraduate'),
                ('Clarendon Fund', 'Oxford University', 'International', 'Full Funding', 'PhD'),
                ('Oxford Reach Scholarship', 'Oxford University', 'Need-based', 'Partial Funding', 'Undergraduate'),
                ('Weidenfeld-Hoffmann Trust', 'Oxford University', 'International', 'Full Funding', 'Masters')
            ON CONFLICT DO NOTHING;
        `;
        
        await pool.query(scholarshipsQuery);
        console.log('✅ Scholarships added successfully');
        
        // Verify the data
        const coursesResult = await pool.query(
            "SELECT COUNT(*) as course_count FROM public.courses WHERE university = 'Oxford University'"
        );
        
        const scholarshipsResult = await pool.query(
            "SELECT COUNT(*) as scholarship_count FROM public.scholarships WHERE university_name = 'Oxford University'"
        );
        
        console.log('📊 Data verification:');
        console.log(`Courses for Oxford University: ${coursesResult.rows[0].course_count}`);
        console.log(`Scholarships for Oxford University: ${scholarshipsResult.rows[0].scholarship_count}`);
        
    } catch (error) {
        console.error('❌ Error adding data:', error.message);
    } finally {
        process.exit(0);
    }
}

// Run the data addition
addOxfordData();
