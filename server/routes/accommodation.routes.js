console.log('🔄 ACCOMMODATION ROUTES - Starting module load...');

const express = require('express');
const authenticateToken = require('../middlewares/auth.middleware');
const { 
  createNewAccommodation, 
  fetchAccommodations, 
  fetchAccommodationById, 
  updateExistingAccommodation, 
  removeAccommodation,
  fetchUserAccommodations,
  uploadAccommodationImages 
} = require('../services/accommodation.service');

// Import and configure multer for file uploads
const multer = require('multer');
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB per file
    files: 5 // Maximum 5 files
  },
  fileFilter: (req, file, cb) => {
    // Check if file is an image
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

const router = express.Router();

console.log('✅ ACCOMMODATION ROUTES - All dependencies loaded');

// GET /accommodations - Get all accommodations (Public)
router.get('/', async (req, res) => {
  console.log('\n📋 GET /accommodations - Route called');
  console.log('🔍 Query params:', req.query);
  
  try {
    const accommodations = await fetchAccommodations(req.query);
    console.log(`✅ Found ${accommodations.length} accommodations`);
    
    res.json({
      success: true,
      data: accommodations,
      count: accommodations.length
    });
    
  } catch (error) {
    console.error('❌ GET ACCOMMODATIONS ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch accommodations',
      message: error.message
    });
  }
});

// GET /accommodations/:id - Get accommodation by ID (Public)
router.get('/:id', async (req, res) => {
  console.log('\n🔍 GET /accommodations/:id - Route called');
  console.log('🆔 Accommodation ID:', req.params.id);
  
  try {
    const accommodationId = parseInt(req.params.id);
    
    if (isNaN(accommodationId)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID'
      });
    }

    const accommodation = await fetchAccommodationById(accommodationId);
    
    if (!accommodation) {
      return res.status(404).json({
        success: false,
        error: 'Accommodation not found'
      });
    }
    
    console.log('✅ Accommodation found');
    res.json({
      success: true,
      data: accommodation
    });
    
  } catch (error) {
    console.error('❌ GET ACCOMMODATION ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch accommodation',
      message: error.message
    });
  }
});

// POST /accommodations - Create new accommodation (Protected)
router.post('/', authenticateToken, async (req, res) => {
  console.log('\n🏠 POST /accommodations - Route called');
  console.log('👤 User ID:', req.user.id);
  console.log('📋 Request body keys:', Object.keys(req.body));
  
  try {
    const accommodationData = {
      ...req.body,
      user_id: req.user.id // Ensure user_id is set from authenticated user
    };
    
    console.log('🔍 Processing accommodation data:', {
      title: accommodationData.title,
      location: accommodationData.location,
      price: accommodationData.price,
      user_id: accommodationData.user_id
    });

    const newAccommodation = await createNewAccommodation(accommodationData);
    
    console.log('✅ Accommodation created with ID:', newAccommodation.id);
    res.status(201).json({
      success: true,
      message: 'Accommodation created successfully',
      data: newAccommodation
    });
    
  } catch (error) {
    console.error('❌ CREATE ACCOMMODATION ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to create accommodation',
      message: error.message
    });
  }
});

// GET /accommodations/user/my - Get current user's accommodations (Protected)
router.get('/user/my', authenticateToken, async (req, res) => {
  console.log('\n👤 GET /accommodations/user/my - Route called');
  console.log('👤 User ID:', req.user.id);
  
  try {
    const userAccommodations = await fetchUserAccommodations(req.user.id);
    console.log(`✅ Found ${userAccommodations.length} user accommodations`);
    
    res.json({
      success: true,
      data: userAccommodations,
      count: userAccommodations.length
    });
    
  } catch (error) {
    console.error('❌ GET USER ACCOMMODATIONS ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch your accommodations',
      message: error.message
    });
  }
});

// PUT /accommodations/:id - Update accommodation (Protected)
router.put('/:id', authenticateToken, async (req, res) => {
  console.log('\n✏️ PUT /accommodations/:id - Route called');
  console.log('🆔 Accommodation ID:', req.params.id);
  console.log('👤 User ID:', req.user.id);
  console.log('📋 Request body keys:', Object.keys(req.body));
  
  try {
    const accommodationId = parseInt(req.params.id);
    
    if (isNaN(accommodationId)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID'
      });
    }

    const updatedAccommodation = await updateExistingAccommodation(accommodationId, req.body, req.user.id);
    
    if (!updatedAccommodation) {
      return res.status(404).json({
        success: false,
        error: 'Accommodation not found or you do not have permission to update it'
      });
    }
    
    console.log('✅ Accommodation updated successfully');
    res.json({
      success: true,
      message: 'Accommodation updated successfully',
      data: updatedAccommodation
    });
    
  } catch (error) {
    console.error('❌ UPDATE ACCOMMODATION ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to update accommodation',
      message: error.message
    });
  }
});

// DELETE /accommodations/:id - Delete accommodation (Protected)
router.delete('/:id', authenticateToken, async (req, res) => {
  console.log('\n🗑️ DELETE /accommodations/:id - Route called');
  console.log('🆔 Accommodation ID:', req.params.id);
  console.log('👤 User ID:', req.user.id);
  
  try {
    const accommodationId = parseInt(req.params.id);
    
    if (isNaN(accommodationId)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID'
      });
    }

    const deletedAccommodation = await removeAccommodation(accommodationId, req.user.id);
    
    if (!deletedAccommodation) {
      return res.status(404).json({
        success: false,
        error: 'Accommodation not found or you do not have permission to delete it'
      });
    }
    
    console.log('✅ Accommodation deleted successfully');
    res.json({
      success: true,
      message: 'Accommodation deleted successfully',
      data: deletedAccommodation
    });
    
  } catch (error) {
    console.error('❌ DELETE ACCOMMODATION ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to delete accommodation',
      message: error.message
    });
  }
});

// POST /accommodations/:id/images - Upload images to specific accommodation (Protected)
router.post('/:id/images', authenticateToken, upload.array('images', 5), async (req, res) => {
  console.log('\n🖼️ POST /accommodations/:id/images - Route called');
  console.log('🆔 Accommodation ID:', req.params.id);
  console.log('👤 User ID:', req.user.id);
  console.log('📸 Number of files:', req.files ? req.files.length : 0);
  
  try {
    const accommodationId = parseInt(req.params.id);
    
    if (isNaN(accommodationId)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID'
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No images provided'
      });
    }

    console.log('📋 File details:', req.files.map(f => ({
      originalname: f.originalname,
      mimetype: f.mimetype,
      size: f.size
    })));

    const imageUrls = await uploadAccommodationImages(req.files, req.user.id, accommodationId);
    
    console.log('✅ Images uploaded successfully');
    res.json({
      success: true,
      message: 'Images uploaded successfully',
      data: {
        imageUrls: imageUrls,
        count: imageUrls.length
      }
    });
    
  } catch (error) {
    console.error('❌ UPLOAD IMAGES ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to upload images',
      message: error.message
    });
  }
});

// POST /accommodations/upload-images - Upload images to Supabase Storage (Protected)
router.post('/upload-images', authenticateToken, upload.array('images', 5), async (req, res) => {
  console.log('\n🖼️ POST /accommodations/upload-images - Route called');
  console.log('👤 User ID:', req.user.id);
  console.log('📸 Number of files:', req.files ? req.files.length : 0);
  
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No images provided'
      });
    }

    console.log('📋 File details:', req.files.map(f => ({
      originalname: f.originalname,
      mimetype: f.mimetype,
      size: f.size
    })));

    // Upload images without accommodation ID (general upload)
    const imageUrls = await uploadAccommodationImages(req.files, req.user.id);
    
    console.log('✅ Images uploaded successfully');
    res.json({
      success: true,
      message: 'Images uploaded successfully',
      data: {
        imageUrls: imageUrls,
        count: imageUrls.length
      }
    });
    
  } catch (error) {
    console.error('❌ UPLOAD IMAGES ERROR:', error.message);
    res.status(500).json({
      success: false,
      error: 'Failed to upload images',
      message: error.message
    });
  }
});

console.log('✅ ACCOMMODATION ROUTES - All routes defined successfully');

module.exports = router;
