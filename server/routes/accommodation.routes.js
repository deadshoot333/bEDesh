console.log('🔄 ACCOMMODATION ROUTES - Starting module load...');

const express = require('express');
const authenticateToken = require('../middlewares/auth.middleware');
const { supabase } = require('../config/connection');
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
    fileSize: 10 * 1024 * 1024, // 10MB per file
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
    const accommodationId = req.params.id;
    
    // Validate UUID format (basic check)
    if (!accommodationId || accommodationId.length < 10) {
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
  console.log('👤 User ID:', req.user.userId);
  console.log('📋 Request body keys:', Object.keys(req.body));
  
  try {
    const accommodationData = req.body;
    
    console.log('🔍 Processing accommodation data:', {
      title: accommodationData.title,
      location: accommodationData.location,
      rent: accommodationData.rent,
      roomType: accommodationData.roomType
    });

    const newAccommodation = await createNewAccommodation(accommodationData, req.user.userId);
    
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
  console.log('👤 User ID:', req.user.userId);
  
  try {
    const userAccommodations = await fetchUserAccommodations(req.user.userId);
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
  console.log('👤 User ID:', req.user.userId);
  console.log('📋 Request body keys:', Object.keys(req.body));
  
  try {
    const accommodationId = req.params.id;
    
    // Validate UUID format (basic check)
    if (!accommodationId || accommodationId.length < 10) {
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID'
      });
    }

    const updatedAccommodation = await updateExistingAccommodation(accommodationId, req.body, req.user.userId);
    
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
  console.log('👤 User ID:', req.user.userId);
  
  try {
    const accommodationId = req.params.id;
    
    // Validate UUID format (basic check)
    if (!accommodationId || accommodationId.length < 10) {
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID'
      });
    }

    const deletedAccommodation = await removeAccommodation(accommodationId, req.user.userId);
    
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
  console.log('🆔 ID Type:', typeof req.params.id);
  console.log('👤 User ID:', req.user.userId);
  console.log('� User from token:', JSON.stringify(req.user, null, 2));
  console.log('�📸 Number of files:', req.files ? req.files.length : 0);
  console.log('📋 Headers:', JSON.stringify(req.headers, null, 2));
  
  try {
    const accommodationId = req.params.id;
    
    // Enhanced UUID validation
    console.log('🔍 Validating accommodation ID...');
    if (!accommodationId) {
      console.error('❌ No accommodation ID provided');
      return res.status(400).json({
        success: false,
        error: 'Accommodation ID is required'
      });
    }
    
    if (typeof accommodationId !== 'string') {
      console.error('❌ Accommodation ID is not a string:', typeof accommodationId);
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID format'
      });
    }
    
    if (accommodationId.length < 10) {
      console.error('❌ Accommodation ID too short:', accommodationId.length);
      return res.status(400).json({
        success: false,
        error: 'Invalid accommodation ID length'
      });
    }
    
    console.log('✅ Accommodation ID validation passed');

    // Validate files
    console.log('🔍 Validating uploaded files...');
    if (!req.files || req.files.length === 0) {
      console.error('❌ No files provided in request');
      return res.status(400).json({
        success: false,
        error: 'No images provided'
      });
    }

    console.log('📋 Detailed file information:');
    req.files.forEach((file, index) => {
      console.log(`  📁 File ${index + 1}:`, {
        originalname: file.originalname,
        mimetype: file.mimetype,
        size: file.size,
        encoding: file.encoding,
        bufferLength: file.buffer ? file.buffer.length : 'No buffer'
      });
    });

    // Test Supabase connection (simplified)
    console.log('🔗 Testing Supabase storage access...');
    try {
      // Skip bucket listing due to RLS policies, go straight to upload test
      console.log('ℹ️ Skipping bucket existence check due to RLS policies');
      console.log('✅ Proceeding with upload - bucket exists in dashboard');
    } catch (connectionError) {
      console.error('❌ Supabase connection test failed:', connectionError.message);
      console.error('❌ Full connection error:', connectionError);
      return res.status(500).json({
        success: false,
        error: 'Storage service connection failed',
        details: connectionError.message
      });
    }

    console.log('🚀 Starting image upload process...');
    const imageUrls = await uploadAccommodationImages(req.files, req.user.userId, accommodationId);
    
    console.log('✅ Images uploaded and accommodation updated successfully');
    console.log('📊 Upload summary:', {
      totalFiles: req.files.length,
      successfulUploads: imageUrls.length,
      imageUrls: imageUrls
    });
    
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
    console.error('❌ Error stack:', error.stack);
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
  console.log('👤 User ID:', req.user.userId);
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
    const imageUrls = await uploadAccommodationImages(req.files, req.user.userId);
    
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
