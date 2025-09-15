console.log('🔄 ACCOMMODATION SERVICE - Starting module load...');

const {
  createAccommodation,
  getAccommodations,
  getAccommodationById,
  updateAccommodation,
  deleteAccommodation,
  getAccommodationsByUserId
} = require('../models/accommodation.model.js');

const { supabase } = require('../config/connection');
console.log('✅ Accommodation model and Supabase client loaded');

// Create new accommodation
async function createNewAccommodation(accommodationData, userId) {
  console.log('\n🏠 ACCOMMODATION SERVICE - createNewAccommodation called');
  console.log('👤 User ID:', userId);
  console.log('📝 Accommodation data:', JSON.stringify(accommodationData, null, 2));
  
  try {
    // Validate required fields
    const requiredFields = ['title', 'location', 'rent', 'contactEmail'];
    for (const field of requiredFields) {
      if (!accommodationData[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }

    // Prepare data for database
    const dbData = {
      user_id: userId,
      title: accommodationData.title,
      location: accommodationData.location,
      rent: parseFloat(accommodationData.rent),
      rent_period: accommodationData.rentPeriod || 'month',
      contact_email: accommodationData.contactEmail,
      available_from: accommodationData.availableFrom,
      available_to: accommodationData.availableTo || null,
      gender_preference: accommodationData.genderPreference || 'any',
      facilities: accommodationData.facilities || [],
      description: accommodationData.description || '',
      image_urls: accommodationData.imageUrls || [],
      is_roommate_request: accommodationData.isRoommateRequest || false
    };

    console.log('🔧 Prepared database data:', JSON.stringify(dbData, null, 2));

    const accommodation = await createAccommodation(dbData);
    
    console.log('✅ Accommodation created with ID:', accommodation.id);
    return accommodation;
    
  } catch (error) {
    console.error('❌ CREATE ACCOMMODATION SERVICE ERROR:', error.message);
    throw error;
  }
}

// Get accommodations with filters
async function fetchAccommodations(filters = {}) {
  console.log('\n🔍 ACCOMMODATION SERVICE - fetchAccommodations called');
  console.log('🔧 Filters:', JSON.stringify(filters, null, 2));
  
  try {
    const accommodations = await getAccommodations(filters);
    
    // Process accommodations for frontend
    const processedAccommodations = accommodations.map(acc => ({
      id: acc.id,
      title: acc.title,
      location: acc.location,
      rent: acc.rent,
      rentPeriod: acc.rent_period,
      contactEmail: acc.contact_email,
      availableFrom: acc.available_from,
      availableTo: acc.available_to,
      genderPreference: acc.gender_preference,
      facilities: typeof acc.facilities === 'string' ? JSON.parse(acc.facilities) : acc.facilities,
      description: acc.description,
      imageUrls: acc.image_urls || [],
      isRoommateRequest: acc.is_roommate_request,
      postedDate: acc.created_at,
      updatedDate: acc.updated_at,
      userEmail: acc.user_email,
      userMobile: acc.user_mobile
    }));
    
    console.log(`✅ Processed ${processedAccommodations.length} accommodations`);
    return processedAccommodations;
    
  } catch (error) {
    console.error('❌ FETCH ACCOMMODATIONS SERVICE ERROR:', error.message);
    throw error;
  }
}

// Get single accommodation by ID
async function fetchAccommodationById(id) {
  console.log('\n🔍 ACCOMMODATION SERVICE - fetchAccommodationById called');
  console.log('🆔 ID:', id);
  
  try {
    const accommodation = await getAccommodationById(id);
    
    if (!accommodation) {
      return null;
    }

    // Process accommodation for frontend
    const processedAccommodation = {
      id: accommodation.id,
      title: accommodation.title,
      location: accommodation.location,
      rent: accommodation.rent,
      rentPeriod: accommodation.rent_period,
      contactEmail: accommodation.contact_email,
      availableFrom: accommodation.available_from,
      availableTo: accommodation.available_to,
      genderPreference: accommodation.gender_preference,
      facilities: typeof accommodation.facilities === 'string' ? JSON.parse(accommodation.facilities) : accommodation.facilities,
      description: accommodation.description,
      imageUrls: accommodation.image_urls || [],
      isRoommateRequest: accommodation.is_roommate_request,
      postedDate: accommodation.created_at,
      updatedDate: accommodation.updated_at,
      userEmail: accommodation.user_email,
      userMobile: accommodation.user_mobile
    };
    
    console.log('✅ Accommodation processed successfully');
    return processedAccommodation;
    
  } catch (error) {
    console.error('❌ FETCH ACCOMMODATION BY ID SERVICE ERROR:', error.message);
    throw error;
  }
}

// Update accommodation
async function updateExistingAccommodation(id, accommodationData, userId) {
  console.log('\n✏️ ACCOMMODATION SERVICE - updateExistingAccommodation called');
  console.log('🆔 ID:', id);
  console.log('👤 User ID:', userId);
  
  try {
    // First check if accommodation exists and belongs to user
    const existingAccommodation = await getAccommodationById(id);
    
    if (!existingAccommodation) {
      throw new Error('Accommodation not found');
    }
    
    if (existingAccommodation.user_id !== userId) {
      throw new Error('Unauthorized: You can only update your own accommodations');
    }

    // Prepare update data
    const updateData = {};
    
    if (accommodationData.title !== undefined) updateData.title = accommodationData.title;
    if (accommodationData.location !== undefined) updateData.location = accommodationData.location;
    if (accommodationData.rent !== undefined) updateData.rent = parseFloat(accommodationData.rent);
    if (accommodationData.rentPeriod !== undefined) updateData.rent_period = accommodationData.rentPeriod;
    if (accommodationData.contactEmail !== undefined) updateData.contact_email = accommodationData.contactEmail;
    if (accommodationData.availableFrom !== undefined) updateData.available_from = accommodationData.availableFrom;
    if (accommodationData.availableTo !== undefined) updateData.available_to = accommodationData.availableTo;
    if (accommodationData.genderPreference !== undefined) updateData.gender_preference = accommodationData.genderPreference;
    if (accommodationData.facilities !== undefined) updateData.facilities = accommodationData.facilities;
    if (accommodationData.description !== undefined) updateData.description = accommodationData.description;
    if (accommodationData.imageUrls !== undefined) updateData.image_urls = accommodationData.imageUrls;
    if (accommodationData.isRoommateRequest !== undefined) updateData.is_roommate_request = accommodationData.isRoommateRequest;

    const updatedAccommodation = await updateAccommodation(id, updateData);
    
    console.log('✅ Accommodation updated successfully');
    return updatedAccommodation;
    
  } catch (error) {
    console.error('❌ UPDATE ACCOMMODATION SERVICE ERROR:', error.message);
    throw error;
  }
}

// Delete accommodation
async function removeAccommodation(id, userId) {
  console.log('\n🗑️ ACCOMMODATION SERVICE - removeAccommodation called');
  console.log('🆔 ID:', id);
  console.log('👤 User ID:', userId);
  
  try {
    // First check if accommodation exists and belongs to user
    const existingAccommodation = await getAccommodationById(id);
    
    if (!existingAccommodation) {
      throw new Error('Accommodation not found');
    }
    
    if (existingAccommodation.user_id !== userId) {
      throw new Error('Unauthorized: You can only delete your own accommodations');
    }

    // Delete images from Supabase Storage if they exist
    if (existingAccommodation.image_urls && existingAccommodation.image_urls.length > 0) {
      console.log('🖼️ Deleting associated images from storage...');
      try {
        const imageFileNames = existingAccommodation.image_urls.map(url => {
          // Extract filename from URL
          return url.split('/').pop();
        });
        
        const { error: deleteError } = await supabase.storage
          .from('accommodation-images')
          .remove(imageFileNames);
          
        if (deleteError) {
          console.warn('⚠️ Warning: Failed to delete some images from storage:', deleteError.message);
        } else {
          console.log('✅ Images deleted from storage successfully');
        }
      } catch (imageError) {
        console.warn('⚠️ Warning: Error deleting images from storage:', imageError.message);
      }
    }

    const deletedAccommodation = await deleteAccommodation(id);
    
    console.log('✅ Accommodation deleted successfully');
    return deletedAccommodation;
    
  } catch (error) {
    console.error('❌ DELETE ACCOMMODATION SERVICE ERROR:', error.message);
    throw error;
  }
}

// Get user's accommodations
async function fetchUserAccommodations(userId) {
  console.log('\n👤 ACCOMMODATION SERVICE - fetchUserAccommodations called');
  console.log('👤 User ID:', userId);
  
  try {
    const accommodations = await getAccommodationsByUserId(userId);
    
    // Process accommodations for frontend
    const processedAccommodations = accommodations.map(acc => ({
      id: acc.id,
      title: acc.title,
      location: acc.location,
      rent: acc.rent,
      rentPeriod: acc.rent_period,
      contactEmail: acc.contact_email,
      availableFrom: acc.available_from,
      availableTo: acc.available_to,
      genderPreference: acc.gender_preference,
      facilities: typeof acc.facilities === 'string' ? JSON.parse(acc.facilities) : acc.facilities,
      description: acc.description,
      imageUrls: acc.image_urls || [],
      isRoommateRequest: acc.is_roommate_request,
      postedDate: acc.created_at,
      updatedDate: acc.updated_at
    }));
    
    console.log(`✅ Processed ${processedAccommodations.length} user accommodations`);
    return processedAccommodations;
    
  } catch (error) {
    console.error('❌ FETCH USER ACCOMMODATIONS SERVICE ERROR:', error.message);
    throw error;
  }
}

// Upload images to Supabase Storage
async function uploadAccommodationImages(imageFiles, userId, accommodationId = null) {
  console.log('\n🖼️ ACCOMMODATION SERVICE - uploadAccommodationImages called');
  console.log('👤 User ID:', userId);
  console.log('🏠 Accommodation ID:', accommodationId);
  console.log('📸 Number of images:', imageFiles.length);
  
  try {
    const uploadedUrls = [];
    
    for (let i = 0; i < imageFiles.length; i++) {
      const file = imageFiles[i];
      const timestamp = Date.now();
      const randomSuffix = Math.random().toString(36).substring(7);
      
      // Create folder structure: {user-id}/{accommodation-id}/ or {user-id}/ if no accommodation ID
      let folderPath = `${userId}/`;
      if (accommodationId) {
        folderPath += `${accommodationId}/`;
      }
      
      const fileName = `${folderPath}${timestamp}_${randomSuffix}_${file.originalname}`;
      
      console.log(`📤 Uploading image ${i + 1}/${imageFiles.length}: ${fileName}`);
      console.log(`📁 Folder structure: ${folderPath}`);
      
      const { data, error } = await supabase.storage
        .from('accommodation-images')
        .upload(fileName, file.buffer, {
          contentType: file.mimetype,
          cacheControl: '3600'
        });
      
      if (error) {
        console.error(`❌ Upload error for image ${i + 1}:`, error.message);
        throw new Error(`Failed to upload image ${i + 1}: ${error.message}`);
      }
      
      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from('accommodation-images')
        .getPublicUrl(fileName);
      
      uploadedUrls.push(publicUrl);
      console.log(`✅ Image ${i + 1} uploaded successfully: ${fileName}`);
    }
    
    console.log(`✅ All ${uploadedUrls.length} images uploaded successfully`);
    return uploadedUrls;
    
  } catch (error) {
    console.error('❌ UPLOAD IMAGES SERVICE ERROR:', error.message);
    throw error;
  }
}

console.log('✅ ACCOMMODATION SERVICE - Module loaded successfully');

module.exports = {
  createNewAccommodation,
  fetchAccommodations,
  fetchAccommodationById,
  updateExistingAccommodation,
  removeAccommodation,
  fetchUserAccommodations,
  uploadAccommodationImages
};
