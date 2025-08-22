const { pool } = require("./config/connection.js");

async function updateUKImages() {
    try {
        console.log('🔧 Updating UK image URLs...');
        
        // Update UK images with working URLs
        await pool.query(`
            UPDATE public.countries 
            SET 
                img_url = 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                flag_url = 'https://images.unsplash.com/photo-1564509670961-f0b2ebb6bbf9?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'
            WHERE name = 'United Kingdom'
        `);
        
        console.log('✅ UK images updated successfully');
        
        // Verify the update
        const result = await pool.query("SELECT name, img_url, flag_url FROM public.countries WHERE name = 'United Kingdom'");
        console.log('🔍 Updated UK data:', result.rows[0]);
        
    } catch (error) {
        console.error('❌ Error updating UK images:', error.message);
    } finally {
        process.exit(0);
    }
}

updateUKImages();
