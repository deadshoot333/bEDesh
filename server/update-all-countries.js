const { pool } = require("./config/connection.js");

async function updateAllCountryImages() {
    try {
        console.log('🔧 Updating all country image URLs with reliable sources...');
        
        // Update all countries with working Unsplash URLs
        const updates = [
            {
                name: 'United States',
                img_url: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                flag_url: 'https://images.unsplash.com/photo-1484727288368-ecbbd77af9c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'
            },
            {
                name: 'Canada',
                img_url: 'https://images.unsplash.com/photo-1503614472-8c93d56cd938?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                flag_url: 'https://images.unsplash.com/photo-1484728101022-ed1baf1d3f74?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'
            },
            {
                name: 'Australia',
                img_url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                flag_url: 'https://images.unsplash.com/photo-1563299396-bc506ba4c7c6?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'
            }
        ];
        
        for (const country of updates) {
            await pool.query(`
                UPDATE public.countries 
                SET 
                    img_url = $1,
                    flag_url = $2
                WHERE name = $3
            `, [country.img_url, country.flag_url, country.name]);
            
            console.log(`✅ Updated ${country.name} images`);
        }
        
        console.log('✅ All country images updated successfully');
        
        // Verify the updates
        const result = await pool.query("SELECT name, img_url, flag_url FROM public.countries ORDER BY name");
        console.log('\n🔍 All updated countries:');
        result.rows.forEach((row, index) => {
            console.log(`${index + 1}. ${row.name}`);
            console.log(`   🖼️  ${row.img_url}`);
            console.log(`   🏳️  ${row.flag_url}\n`);
        });
        
    } catch (error) {
        console.error('❌ Error updating country images:', error.message);
    } finally {
        process.exit(0);
    }
}

updateAllCountryImages();
