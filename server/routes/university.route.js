const express = require('express');
const { 
  getAllUniversity, 
  getUniversityByName, 
  getCoursesByUniversity, 
  getScholarshipsByUniversity,
  searchUniversities 
} = require('../models/university.model');
const router = express.Router();

// Get all universities
router.get('/all-universities', async (req, res) => {
  try {
    const universities = await getAllUniversity();
    res.json({ universities });
  } catch (error) {
    console.error('Error fetching universities:', error);
    res.status(500).json({ error: 'Failed to fetch universities' });
  }
});

// Get university by name
router.get('/by-name/:name', async (req, res) => {
  try {
    const { name } = req.params;
    console.log('🔍 Searching for university:', name);
    console.log('🔍 Decoded name:', decodeURIComponent(name));
    
    const university = await getUniversityByName(decodeURIComponent(name));
    console.log('📊 University found:', university ? 'YES' : 'NO');
    
    if (!university) {
      console.log('❌ University not found');
      return res.status(404).json({ error: 'University not found' });
    }
    
    console.log('✅ Returning university data');
    res.json({ university });
  } catch (error) {
    console.error('❌ Error fetching university:', error);
    res.status(500).json({ error: 'Failed to fetch university' });
  }
});

// Get courses by university
router.get('/courses/:universityName', async (req, res) => {
  try {
    const { universityName } = req.params;
    const courses = await getCoursesByUniversity(universityName);
    res.json({ courses });
  } catch (error) {
    console.error('Error fetching courses:', error);
    res.status(500).json({ error: 'Failed to fetch courses' });
  }
});

// Get scholarships by university
router.get('/scholarships/:universityName', async (req, res) => {
  try {
    const { universityName } = req.params;
    const scholarships = await getScholarshipsByUniversity(universityName);
    res.json({ scholarships });
  } catch (error) {
    console.error('Error fetching scholarships:', error);
    res.status(500).json({ error: 'Failed to fetch scholarships' });
  }
});

// Search universities
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ error: 'Search query is required' });
    }
    const universities = await searchUniversities(q);
    res.json({ universities });
  } catch (error) {
    console.error('Error searching universities:', error);
    res.status(500).json({ error: 'Failed to search universities' });
  }
});

module.exports = router;
//Inserted the data of All university course offered by Oxford University, as it is the university we are focusing on initially.