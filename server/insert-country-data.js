const { pool } = require("./config/connection.js");

async function insertCountryData() {
    try {
        console.log('🌍 Inserting country data...');
        
        // Check if countries table exists and its structure
        const structureQuery = `
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = 'countries'
            ORDER BY ordinal_position;
        `;
        
        const structureResult = await pool.query(structureQuery);
        console.log('📊 Countries table structure:');
        structureResult.rows.forEach(row => {
            console.log(`  - ${row.column_name}: ${row.data_type}`);
        });
        
        // Insert sample country data based on the database structure
        const insertCountriesQuery = `
            INSERT INTO public.countries (name, international_student, happiness_ranking, employment_rate, img_url, flag_url, country_description)
            VALUES 
                ('United Kingdom', '758K', '20', '75%', 'https://i.pinimg.com/736x/0b/e9/8c/0be98c1edb406b89e0ef2a3d7b8a4b1b.jpg', 'https://i.pinimg.com/1200x/d9/fd/68/d9fd68a776b8b76b1e5c7c7d8a8a0f60.jpg', 'The United Kingdom stands as a beacon of academic excellence, offering a world-class education system that has shaped global leaders for centuries. Home to some of the world''s most prestigious institutions, including Oxford, Cambridge, and Imperial College, the UK provides an unparalleled blend of traditional academic rigor and cutting-edge research opportunities.'),
                ('United States', '950K', '19', '78%', 'https://example.com/usa-img.jpg', 'https://example.com/usa-flag.jpg', 'The United States offers diverse educational opportunities across world-renowned universities and colleges. With cutting-edge research facilities, innovative programs, and a multicultural environment, the US provides students with exceptional academic and professional development opportunities.'),
                ('Australia', '800K', '12', '82%', 'https://example.com/aus-img.jpg', 'https://example.com/aus-flag.jpg', 'Australia is known for its high-quality education system, beautiful landscapes, and welcoming culture. With excellent universities, research opportunities, and post-study work options, Australia offers an ideal environment for international students.'),
                ('Canada', '642K', '15', '80%', 'https://example.com/canada-img.jpg', 'https://example.com/canada-flag.jpg', 'Canada offers world-class education in a safe, multicultural environment. Known for its research excellence, affordable tuition, and welcoming immigration policies, Canada is an excellent choice for international students seeking quality education and career opportunities.')
            ON CONFLICT (name) DO UPDATE SET
                international_student = EXCLUDED.international_student,
                happiness_ranking = EXCLUDED.happiness_ranking,
                employment_rate = EXCLUDED.employment_rate,
                img_url = EXCLUDED.img_url,
                flag_url = EXCLUDED.flag_url,
                country_description = EXCLUDED.country_description;
        `;
        
        await pool.query(insertCountriesQuery);
        console.log('✅ Countries data inserted successfully');
        
        // Verify the data
        const verifyQuery = "SELECT name, international_student, happiness_ranking FROM public.countries";
        const result = await pool.query(verifyQuery);
        
        console.log('📊 Inserted countries:');
        result.rows.forEach((country, index) => {
            console.log(`  ${index + 1}. ${country.name} - ${country.international_student} students - Rank ${country.happiness_ranking}`);
        });
        
    } catch (error) {
        console.error('❌ Error inserting country data:', error.message);
        console.error('Full error:', error);
    } finally {
        process.exit(0);
    }
}

insertCountryData();
