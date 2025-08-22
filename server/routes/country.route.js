const express = require('express');
const { getAllCountry, getCountryByName } = require('../models/country.model');
const router = express.Router();

// Get all countries
router.get('/all-countries', async (req, res) => {
  try {
    console.log('🌍 Fetching all countries...');
    const countries = await getAllCountry();
    console.log(`📊 Found ${countries.length} countries`);
    res.json({ countries });
  } catch (error) {
    console.error('❌ Error fetching countries:', error);
    res.status(500).json({ error: 'Failed to fetch countries' });
  }
});

// Get country by name
router.get('/by-name/:name', async (req, res) => {
  try {
    const { name } = req.params;
    console.log('🔍 Searching for country:', name);
    console.log('🔍 Decoded name:', decodeURIComponent(name));
    
    const country = await getCountryByName(decodeURIComponent(name));
    console.log('📊 Country found:', country ? 'YES' : 'NO');
    
    if (!country) {
      console.log('❌ Country not found');
      return res.status(404).json({ error: 'Country not found' });
    }
    
    console.log('✅ Returning country data');
    res.json({ country });
  } catch (error) {
    console.error('❌ Error fetching country:', error);
    res.status(500).json({ error: 'Failed to fetch country' });
  }
});

module.exports = router;
