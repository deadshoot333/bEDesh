const { pool } = require("./config/connection.js");

async function testImageUrls() {
    try {
        console.log('🧪 Testing image URLs from database...');
        
        const result = await pool.query("SELECT name, img_url, flag_url FROM public.countries");
        
        console.log('📊 Countries and their image URLs:');
        result.rows.forEach((country, index) => {
            console.log(`\n${index + 1}. ${country.name}`);
            console.log(`   🖼️  Image URL: ${country.img_url}`);
            console.log(`   🏳️  Flag URL: ${country.flag_url}`);
        });
        
        // Test if URLs are accessible
        console.log('\n🌐 Testing URL accessibility...');
        const https = require('https');
        const http = require('http');
        
        for (const country of result.rows) {
            console.log(`\n🔍 Testing ${country.name}:`);
            
            // Test image URL
            try {
                const imgUrlTester = country.img_url.startsWith('https') ? https : http;
                await new Promise((resolve, reject) => {
                    const req = imgUrlTester.get(country.img_url, (res) => {
                        console.log(`   🖼️  Image URL Status: ${res.statusCode}`);
                        resolve();
                    });
                    req.on('error', (err) => {
                        console.log(`   ❌ Image URL Error: ${err.message}`);
                        resolve();
                    });
                    req.setTimeout(5000, () => {
                        console.log(`   ⏱️  Image URL Timeout`);
                        req.destroy();
                        resolve();
                    });
                });
            } catch (err) {
                console.log(`   ❌ Image URL Test Error: ${err.message}`);
            }
            
            // Test flag URL
            try {
                const flagUrlTester = country.flag_url.startsWith('https') ? https : http;
                await new Promise((resolve, reject) => {
                    const req = flagUrlTester.get(country.flag_url, (res) => {
                        console.log(`   🏳️  Flag URL Status: ${res.statusCode}`);
                        resolve();
                    });
                    req.on('error', (err) => {
                        console.log(`   ❌ Flag URL Error: ${err.message}`);
                        resolve();
                    });
                    req.setTimeout(5000, () => {
                        console.log(`   ⏱️  Flag URL Timeout`);
                        req.destroy();
                        resolve();
                    });
                });
            } catch (err) {
                console.log(`   ❌ Flag URL Test Error: ${err.message}`);
            }
        }
        
    } catch (error) {
        console.error('❌ Error testing image URLs:', error.message);
    } finally {
        process.exit(0);
    }
}

testImageUrls();
