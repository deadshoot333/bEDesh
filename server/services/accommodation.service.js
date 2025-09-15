console.log('🔄 ACCOMMODATION SERVICE - Starting module load...');

const {
  createAccommodation,
  getAccommodations,
  getAccommodationById,
  updateAccommodation,
  updateAccommodationFacilities,
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
    const requiredFields = ['title', 'location', 'rent', 'contactEmail', 'roomType'];
    for (const field of requiredFields) {
      if (!accommodationData[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }

    // Parse location to extract country and city
    let country, city;
    if (accommodationData.location && accommodationData.location.includes(',')) {
      const locationParts = accommodationData.location.split(',').map(part => part.trim());
      city = locationParts[0];
      country = locationParts[1];
    } else {
      // Fallback if location format is unexpected
      city = accommodationData.city || accommodationData.location;
      country = accommodationData.country || 'UK';
    }

    // Prepare data for database
    const dbData = {
      posted_by: userId,
      property_title: accommodationData.title,
      country: country,
      city: city,
      room_type: accommodationData.roomType,
      monthly_rent: parseFloat(accommodationData.rent),
      contact_email: accommodationData.contactEmail,
      availability_from: accommodationData.availableFrom,
      availability_to: accommodationData.availableTo,
      gender_preference: accommodationData.genderPreference || 'Any',
      description: accommodationData.description || '',
      image_urls: accommodationData.imageUrls || [],
      status: accommodationData.status || 'available', // Default to available status
      facilities: accommodationData.facilities || []
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
      title: acc.property_title,
      country: acc.country,
      city: acc.city,
      location: `${acc.city}, ${acc.country}`, // Combine for frontend
      roomType: acc.room_type,
      rent: parseFloat(acc.monthly_rent) || 0, // Convert string to number
      contactEmail: acc.contact_email,
      availableFrom: acc.availability_from,
      availableTo: acc.availability_to,
      genderPreference: acc.gender_preference,
      description: acc.description,
      imageUrls: acc.image_urls || [],
      facilities: acc.facilities || [],
      status: acc.status || 'available', // Add status field
      postedDate: acc.created_at,
      postedBy: acc.posted_by,
      postedByName: acc.posted_by_name || 'Anonymous User'
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
      title: accommodation.property_title,
      country: accommodation.country,
      city: accommodation.city,
      location: `${accommodation.city}, ${accommodation.country}`, // Combine for frontend
      roomType: accommodation.room_type,
      rent: accommodation.monthly_rent,
      contactEmail: accommodation.contact_email,
      availableFrom: accommodation.availability_from,
      availableTo: accommodation.availability_to,
      genderPreference: accommodation.gender_preference,
      description: accommodation.description,
      imageUrls: accommodation.image_urls || [],
      postedDate: accommodation.created_at,
      postedBy: accommodation.posted_by
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
    
    if (existingAccommodation.posted_by !== userId) {
      throw new Error('Unauthorized: You can only update your own accommodations');
    }

    // Prepare update data
    const updateData = {};
    
    if (accommodationData.title !== undefined) updateData.property_title = accommodationData.title;
    if (accommodationData.roomType !== undefined) updateData.room_type = accommodationData.roomType;
    
    // Handle rent/price fields (try multiple field names)
    const rentValue = accommodationData.monthly_rent || accommodationData.price || accommodationData.rent;
    if (rentValue !== undefined) updateData.monthly_rent = parseFloat(rentValue);
    
    // Handle contact info fields (try multiple field names)
    const contactValue = accommodationData.contact_info || accommodationData.contactEmail || accommodationData.contact_email;
    if (contactValue !== undefined) updateData.contact_email = contactValue;
    
    if (accommodationData.availableFrom !== undefined) updateData.availability_from = accommodationData.availableFrom;
    if (accommodationData.availableTo !== undefined) updateData.availability_to = accommodationData.availableTo;
    if (accommodationData.genderPreference !== undefined) updateData.gender_preference = accommodationData.genderPreference;
    if (accommodationData.description !== undefined) updateData.description = accommodationData.description;
    if (accommodationData.imageUrls !== undefined) updateData.image_urls = accommodationData.imageUrls;
    if (accommodationData.status !== undefined) updateData.status = accommodationData.status;
    if (accommodationData.country !== undefined) updateData.country = accommodationData.country;
    if (accommodationData.city !== undefined) updateData.city = accommodationData.city;
    
    // Handle location update (split into country and city)
    if (accommodationData.location !== undefined && accommodationData.location.includes(',')) {
      const locationParts = accommodationData.location.split(',').map(part => part.trim());
      updateData.city = locationParts[0];
      updateData.country = locationParts[1];
    } else if (accommodationData.city !== undefined) {
      updateData.city = accommodationData.city;
    } else if (accommodationData.country !== undefined) {
      updateData.country = accommodationData.country;
    }

    const updatedAccommodation = await updateAccommodation(id, updateData);
    
    // Handle facilities update separately if provided
    if (accommodationData.facilities !== undefined) {
      console.log('🏠 Updating facilities:', accommodationData.facilities);
      try {
        await updateAccommodationFacilities(id, accommodationData.facilities);
        console.log('✅ Facilities updated successfully');
      } catch (facilityError) {
        console.warn('⚠️ Warning: Failed to update facilities:', facilityError.message);
        // Continue with success - accommodation was updated even if facilities failed
      }
    }
    
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
    
    if (existingAccommodation.posted_by !== userId) {
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
          .from('accommodation-pictures')
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
      title: acc.property_title,
      country: acc.country,
      city: acc.city,
      location: `${acc.city}, ${acc.country}`, // Combine for frontend
      roomType: acc.room_type,
      rent: acc.monthly_rent,
      monthly_rent: acc.monthly_rent, // Keep both field names for compatibility
      contactEmail: acc.contact_email,
      contact_info: acc.contact_email, // Map for edit dialog
      availableFrom: acc.availability_from,
      availableTo: acc.availability_to,
      genderPreference: acc.gender_preference,
      description: acc.description,
      imageUrls: acc.image_urls || [],
      facilities: acc.facilities || [], // Include facilities from backend
      status: acc.status || 'available', // Add status field
      posted_by: acc.posted_by, // Include for ownership validation
      posted_by_name: acc.posted_by_name, // Include user name
      postedByName: acc.posted_by_name, // Alternative field name for compatibility
      postedDate: acc.created_at
    }));
    
    console.log(`✅ Processed ${processedAccommodations.length} user accommodations`);
    
    // Debug: Print first accommodation to see the structure
    if (processedAccommodations.length > 0) {
      console.log('🔍 DEBUG - First processed accommodation:', processedAccommodations[0]);
    }
    
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
  console.log('⏰ Upload started at:', new Date().toISOString());
  
  try {
    // Validate inputs
    console.log('🔍 Step 1: Validating inputs...');
    if (!imageFiles || imageFiles.length === 0) {
      throw new Error('No image files provided');
    }
    if (!userId) {
      throw new Error('User ID is required');
    }
    if (!accommodationId) {
      console.warn('⚠️ No accommodation ID provided - uploading to general folder');
    }
    
    console.log('✅ Input validation passed');
    
    const imageUrls = [];
    const uploadResults = [];
    
    console.log('🔍 Step 2: Processing each image file...');
    for (let i = 0; i < imageFiles.length; i++) {
      const imageFile = imageFiles[i];
      console.log(`\n📁 Processing image ${i + 1}/${imageFiles.length}:`);
      console.log(`  📋 Original name: ${imageFile.originalname}`);
      console.log(`  📊 Size: ${imageFile.size} bytes`);
      console.log(`  🎨 MIME type: ${imageFile.mimetype}`);
      console.log(`  📦 Buffer size: ${imageFile.buffer ? imageFile.buffer.length : 'No buffer'} bytes`);
      
      try {
        // Generate unique filename
        console.log('  🔧 Generating unique filename...');
        const fileExt = imageFile.originalname.split('.').pop();
        const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;
        console.log(`  ✅ Generated filename: ${fileName}`);
        
        // Create structured path
        const storagePath = `${userId}/${accommodationId}/${fileName}`;
        console.log(`  � Storage path: ${storagePath}`);
        
        // Upload to Supabase Storage
        console.log(`  📤 Uploading to Supabase storage...`);
        const uploadStartTime = Date.now();
        
        const { data, error } = await supabase.storage
          .from('accommodation-pictures')
          .upload(storagePath, imageFile.buffer, {
            contentType: imageFile.mimetype,
            cacheControl: '3600'
          });
        
        const uploadEndTime = Date.now();
        const uploadDuration = uploadEndTime - uploadStartTime;
        
        if (error) {
          console.error(`  ❌ Upload failed for image ${i + 1}:`, error.message);
          console.error(`  ❌ Error details:`, error);
          console.error(`  ❌ Error status:`, error.status || 'No status');
          console.error(`  ❌ Error statusCode:`, error.statusCode || 'No statusCode');
          
          // Throw error to stop processing and inform controller
          throw new Error(`Upload failed for ${imageFile.originalname}: ${error.message}`);
        }
        
        console.log(`  ✅ Upload successful in ${uploadDuration}ms`);
        console.log(`  📊 Upload data:`, data);
        
        // Get the public URL
        console.log(`  🔗 Generating public URL...`);
        const { data: { publicUrl } } = supabase.storage
          .from('accommodation-pictures')
          .getPublicUrl(storagePath);
        
        console.log(`  ✅ Public URL generated: ${publicUrl}`);
        
        imageUrls.push(publicUrl);
        uploadResults.push({
          index: i + 1,
          filename: imageFile.originalname,
          success: true,
          url: publicUrl,
          duration: uploadDuration,
          size: imageFile.size
        });
        
        console.log(`  🎉 Image ${i + 1} processed successfully`);
        
      } catch (fileError) {
        console.error(`  ❌ Error processing image ${i + 1}:`, fileError.message);
        console.error(`  ❌ Full error details:`, fileError);
        
        // Don't just log and continue - throw the error to fail the entire upload
        throw new Error(`Image upload failed: ${fileError.message}`);
      }
    }
    
    console.log('\n📊 Upload Results Summary:');
    console.log(`  📈 Total files: ${imageFiles.length}`);
    console.log(`  ✅ Successful uploads: ${imageUrls.length}`);
    console.log(`  ❌ Failed uploads: ${imageFiles.length - imageUrls.length}`);
    uploadResults.forEach(result => {
      if (result.success) {
        console.log(`  ✅ ${result.index}: ${result.filename} (${result.size} bytes, ${result.duration}ms)`);
      } else {
        console.log(`  ❌ ${result.index}: ${result.filename} - ${result.error}`);
      }
    });
    
    // Update the database record
    if (accommodationId && imageUrls.length > 0) {
      console.log('\n🔍 Step 3: Updating accommodation record in database...');
      console.log(`📝 Updating accommodation ${accommodationId} with ${imageUrls.length} image URLs`);
      console.log(`📋 Image URLs to save:`, imageUrls);
      
      const dbUpdateStartTime = Date.now();
      
      const { error: updateError } = await supabase
        .from('accommodations')
        .update({ image_urls: imageUrls })
        .eq('id', accommodationId);
      
      const dbUpdateEndTime = Date.now();
      const dbUpdateDuration = dbUpdateEndTime - dbUpdateStartTime;
      
      if (updateError) {
        console.error('❌ Error updating accommodation with image URLs:', updateError.message);
        console.error('❌ Update error details:', updateError);
        throw new Error(`Database update failed: ${updateError.message}`);
      } else {
        console.log(`✅ Accommodation record updated successfully in ${dbUpdateDuration}ms`);
        console.log('✅ Database update completed');
      }
    } else if (!accommodationId) {
      console.log('ℹ️ No accommodation ID provided - skipping database update');
    } else if (imageUrls.length === 0) {
      console.log('⚠️ No successful uploads - skipping database update');
    }
    
    console.log(`\n🎉 Upload process completed at: ${new Date().toISOString()}`);
    console.log(`✅ Final result: ${imageUrls.length} images uploaded successfully`);
    return imageUrls;
    
  } catch (error) {
    console.error('\n❌ UPLOAD IMAGES SERVICE ERROR:', error.message);
    console.error('❌ Error stack:', error.stack);
    console.error('❌ Upload failed at:', new Date().toISOString());
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
