const { pool } = require("./config/connection.js");

async function updateOxfordImage() {
    try {
        console.log('🖼️ Updating Oxford University image...');
        
        const imageUrl = 'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nojSxQtQ-cVP1a5UrJfK_pdy6iVDEBggYVIUJg_2o3RNI4cNM6-yO8jz2kfWnwE8Q03Ah9ZUJaliRxPwEkosrXXkyBUzKvr0kh-mLAHxvfCjlc5wq_8Cl4a-u1JW1Fb1VG15Gmbwwag0_dY=s1360-w1360-h1020-rw';
        
        const result = await pool.query(
            `UPDATE public.universities 
             SET image_url = $1 
             WHERE name = $2 
             RETURNING name, image_url`,
            [imageUrl, 'Oxford University']
        );
        
        if (result.rows.length > 0) {
            console.log('✅ Successfully updated Oxford University image:');
            console.log('University:', result.rows[0].name);
            console.log('Image URL:', result.rows[0].image_url);
        } else {
            console.log('⚠️ No rows updated. University not found.');
        }
        
        // Verify the update
        const verifyResult = await pool.query(
            'SELECT name, image_url FROM public.universities WHERE name = $1',
            ['Oxford University']
        );
        
        console.log('🔍 Verification:');
        console.log(verifyResult.rows[0]);
        
    } catch (error) {
        console.error('❌ Error updating image:', error.message);
    } finally {
        process.exit(0);
    }
}

// Run the update
updateOxfordImage();
