console.log('🔄 ACCOMMODATION MODEL - Starting module load...');

const { pool } = require('../config/connection');
console.log('✅ Database connection loaded');

// Create a new accommodation
async function createAccommodation(accommodationData) {
  console.log('\n🏠 ACCOMMODATION MODEL - createAccommodation called');
  console.log('📝 Data:', JSON.stringify(accommodationData, null, 2));
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const {
      posted_by,
      property_title,
      country,
      city,
      room_type,
      monthly_rent,
      contact_email,
      availability_from,
      availability_to,
      gender_preference,
      description,
      image_urls,
      facilities,
      status = 'available' // Default status to 'available' if not provided
    } = accommodationData;

    // First, create the accommodation
    const accommodationQuery = `
      INSERT INTO accommodations (
        posted_by, property_title, country, city, room_type, monthly_rent,
        availability_from, availability_to, contact_email, gender_preference,
        description, image_urls, status
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
      ) RETURNING *
    `;

    const accommodationValues = [
      posted_by,
      property_title,
      country,
      city,
      room_type,
      monthly_rent,
      availability_from,
      availability_to,
      contact_email,
      gender_preference,
      description,
      image_urls || [],
      status || 'available'
    ];

    console.log('📊 Executing accommodation query:', accommodationQuery);
    console.log('📊 Accommodation values:', accommodationValues);

    const accommodationResult = await client.query(accommodationQuery, accommodationValues);
    const accommodation = accommodationResult.rows[0];
    
    console.log('✅ Accommodation created successfully:', accommodation.id);

    // Handle facilities if provided
    if (facilities && Array.isArray(facilities) && facilities.length > 0) {
      console.log('🏠 Processing facilities:', facilities);
      
      // Get facility IDs from facility names
      for (const facilityName of facilities) {
        try {
          // First check if facility exists
          const facilityQuery = 'SELECT id FROM facilities WHERE LOWER(name) = LOWER($1)';
          const facilityResult = await client.query(facilityQuery, [facilityName]);
          
          let facilityId;
          if (facilityResult.rows.length > 0) {
            facilityId = facilityResult.rows[0].id;
            console.log(`✅ Found existing facility: ${facilityName} (ID: ${facilityId})`);
          } else {
            // Create new facility if it doesn't exist
            const createFacilityQuery = 'INSERT INTO facilities (name) VALUES ($1) RETURNING id';
            const createFacilityResult = await client.query(createFacilityQuery, [facilityName]);
            facilityId = createFacilityResult.rows[0].id;
            console.log(`✅ Created new facility: ${facilityName} (ID: ${facilityId})`);
          }

          // Link facility to accommodation
          const linkQuery = 'INSERT INTO accommodation_facilities (accommodation_id, facility_id) VALUES ($1, $2) ON CONFLICT DO NOTHING';
          await client.query(linkQuery, [accommodation.id, facilityId]);
          console.log(`✅ Linked facility ${facilityName} to accommodation ${accommodation.id}`);
          
        } catch (facilityError) {
          console.error(`❌ Error processing facility ${facilityName}:`, facilityError.message);
          // Continue with other facilities even if one fails
        }
      }
    }

    await client.query('COMMIT');
    return accommodation;
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ CREATE ACCOMMODATION ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Get accommodations with optional filters
async function getAccommodations(filters = {}) {
  console.log('\n🔍 ACCOMMODATION MODEL - getAccommodations called');
  console.log('🔧 Filters:', JSON.stringify(filters, null, 2));
  
  const client = await pool.connect();
  
  try {
    // 1. First, build the base query for accommodations
    let baseQuery = `
      SELECT 
        a.*,
        u.email as posted_by_name
      FROM accommodations a
      LEFT JOIN users u ON a.posted_by = u.id
      WHERE 1=1
    `;
    
    const baseValues = [];
    let paramCount = 0;

    // Always filter out booked accommodations from public listings (unless explicitly requesting all statuses)
    if (!filters.includeBooked) {
      paramCount++;
      baseQuery += ` AND a.status != $${paramCount}`;
      baseValues.push('booked');
    }

    // Add filters to the BASE query
    if (filters.location) {
      paramCount++;
      baseQuery += ` AND LOWER(a.city) LIKE LOWER($${paramCount})`;
      baseValues.push(`%${filters.location}%`);
    }

    if (filters.max_rent) {
      paramCount++;
      baseQuery += ` AND a.monthly_rent <= $${paramCount}`;
      baseValues.push(filters.max_rent);
    }

    if (filters.min_rent) {
      paramCount++;
      baseQuery += ` AND a.monthly_rent >= $${paramCount}`;
      baseValues.push(filters.min_rent);
    }

    if (filters.gender_preference) {
      paramCount++;
      baseQuery += ` AND a.gender_preference = $${paramCount}`;
      baseValues.push(filters.gender_preference);
    }

    // Add pagination to the base query
    const limit = filters.limit || 20;
    const offset = filters.offset || 0;
    
    baseQuery += ` ORDER BY a.created_at DESC LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}`;
    baseValues.push(limit, offset);

    console.log('📊 BASE QUERY:', baseQuery);
    console.log('📊 BASE VALUES:', baseValues);

    // 2. Execute the base query to get accommodations
    const accommodationsResult = await client.query(baseQuery, baseValues);
    const accommodations = accommodationsResult.rows;
    
    console.log(`✅ Found ${accommodations.length} accommodations from base query`);

    // 3. If no accommodations found, return empty array
    if (accommodations.length === 0) {
      return [];
    }

    // 4. Get accommodation IDs to fetch facilities
    const accommodationIds = accommodations.map(acc => acc.id);
    
    // 5. Fetch facilities for all accommodations in one query
    const facilitiesQuery = `
      SELECT 
        af.accommodation_id,
        json_agg(f.name) as facilities
      FROM accommodation_facilities af
      JOIN facilities f ON af.facility_id = f.id
      WHERE af.accommodation_id = ANY($1)
      GROUP BY af.accommodation_id
    `;
    
    const facilitiesResult = await client.query(facilitiesQuery, [accommodationIds]);
    const facilitiesMap = {};
    
    facilitiesResult.rows.forEach(row => {
      facilitiesMap[row.accommodation_id] = row.facilities;
    });

    console.log('📊 Facilities map:', facilitiesMap);

    // 6. Combine accommodations with their facilities
    const accommodationsWithFacilities = accommodations.map(acc => ({
      ...acc,
      facilities: facilitiesMap[acc.id] || [] // Use empty array if no facilities found
    }));

    console.log(`✅ Final result with ${accommodationsWithFacilities.length} accommodations`);
    return accommodationsWithFacilities;
    
  } catch (error) {
    console.error('❌ GET ACCOMMODATIONS ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Get accommodation by ID
async function getAccommodationById(id) {
  console.log('\n🔍 ACCOMMODATION MODEL - getAccommodationById called');
  console.log('🆔 ID:', id);
  
  const client = await pool.connect();
  
  try {
    const query = `
      SELECT a.*
      FROM accommodations a
      WHERE a.id = $1
    `;

    const result = await client.query(query, [id]);
    const accommodation = result.rows[0];
    
    if (!accommodation) {
      console.log('❌ Accommodation not found');
      return null;
    }
    
    console.log('✅ Accommodation found:', accommodation.property_title);
    return accommodation;
    
  } catch (error) {
    console.error('❌ GET ACCOMMODATION BY ID ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Update accommodation
async function updateAccommodation(id, accommodationData) {
  console.log('\n✏️ ACCOMMODATION MODEL - updateAccommodation called');
  console.log('🆔 ID:', id);
  console.log('📝 Data:', JSON.stringify(accommodationData, null, 2));
  
  const client = await pool.connect();
  
  try {
    // Build dynamic update query
    const fields = [];
    const values = [];
    let paramCount = 0;

    Object.keys(accommodationData).forEach(key => {
      if (accommodationData[key] !== undefined) {
        paramCount++;
        fields.push(`${key} = $${paramCount}`);
        
        // Handle JSON fields
        if (key === 'facilities') {
          values.push(JSON.stringify(accommodationData[key]));
        } else {
          values.push(accommodationData[key]);
        }
      }
    });

    if (fields.length === 0) {
      throw new Error('No fields to update');
    }

    // Add id for WHERE clause
    paramCount++;
    values.push(id);

    const query = `
      UPDATE accommodations 
      SET ${fields.join(', ')} 
      WHERE id = $${paramCount} 
      RETURNING *
    `;

    console.log('📊 Executing query:', query);
    console.log('📊 Query values:', values);

    const result = await client.query(query, values);
    const accommodation = result.rows[0];
    
    if (!accommodation) {
      console.log('❌ Accommodation not found for update');
      return null;
    }
    
    console.log('✅ Accommodation updated successfully');
    return accommodation;
    
  } catch (error) {
    console.error('❌ UPDATE ACCOMMODATION ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Delete accommodation
async function deleteAccommodation(id) {
  console.log('\n🗑️ ACCOMMODATION MODEL - deleteAccommodation called');
  console.log('🆔 ID:', id);
  
  const client = await pool.connect();
  
  try {
    const query = 'DELETE FROM accommodations WHERE id = $1 RETURNING *';
    const result = await client.query(query, [id]);
    const accommodation = result.rows[0];
    
    if (!accommodation) {
      console.log('❌ Accommodation not found for deletion');
      return null;
    }
    
    console.log('✅ Accommodation deleted successfully');
    return accommodation;
    
  } catch (error) {
    console.error('❌ DELETE ACCOMMODATION ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Get accommodations by user ID
async function getAccommodationsByUserId(userId) {
  console.log('\n👤 ACCOMMODATION MODEL - getAccommodationsByUserId called');
  console.log('👤 User ID:', userId);
  
  const client = await pool.connect();
  
  try {
    // 1. First, get the accommodations with user details
    const query = `
      SELECT 
        a.*,
        u.name as posted_by_name
      FROM accommodations a
      LEFT JOIN users u ON a.posted_by = u.id
      WHERE a.posted_by = $1 
      ORDER BY a.created_at DESC
    `;

    const result = await client.query(query, [userId]);
    const accommodations = result.rows;
    
    if (accommodations.length === 0) {
      console.log('✅ No accommodations found for user');
      return [];
    }

    // 2. Get accommodation IDs to fetch facilities
    const accommodationIds = accommodations.map(acc => acc.id);
    
    // 3. Fetch facilities for all accommodations in one query
    const facilitiesQuery = `
      SELECT 
        af.accommodation_id,
        json_agg(f.name) as facilities
      FROM accommodation_facilities af
      JOIN facilities f ON af.facility_id = f.id
      WHERE af.accommodation_id = ANY($1)
      GROUP BY af.accommodation_id
    `;
    
    const facilitiesResult = await client.query(facilitiesQuery, [accommodationIds]);
    const facilitiesMap = {};
    
    // Create a map of accommodation_id -> facilities
    facilitiesResult.rows.forEach(row => {
      facilitiesMap[row.accommodation_id] = row.facilities || [];
    });
    
    // 4. Combine accommodations with their facilities
    const enrichedAccommodations = accommodations.map(accommodation => ({
      ...accommodation,
      facilities: facilitiesMap[accommodation.id] || []
    }));
    
    console.log(`✅ Found ${enrichedAccommodations.length} accommodations for user with facilities`);
    console.log('🔍 DEBUG - First accommodation structure:', enrichedAccommodations[0]);
    return enrichedAccommodations;
    
  } catch (error) {
    console.error('❌ GET USER ACCOMMODATIONS ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

// Update facilities for an accommodation
async function updateAccommodationFacilities(accommodationId, facilities) {
  console.log('\n🏠 ACCOMMODATION MODEL - updateAccommodationFacilities called');
  console.log('🆔 Accommodation ID:', accommodationId);
  console.log('🏠 Facilities:', facilities);
  
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // First, remove all existing facilities for this accommodation
    const deleteQuery = 'DELETE FROM accommodation_facilities WHERE accommodation_id = $1';
    await client.query(deleteQuery, [accommodationId]);
    console.log('🗑️ Existing facilities removed');
    
    // If facilities array is provided and not empty, add new facilities
    if (facilities && Array.isArray(facilities) && facilities.length > 0) {
      for (const facilityName of facilities) {
        try {
          // Check if facility exists, create if not
          const facilityQuery = 'SELECT id FROM facilities WHERE LOWER(name) = LOWER($1)';
          let facilityResult = await client.query(facilityQuery, [facilityName]);
          
          let facilityId;
          if (facilityResult.rows.length === 0) {
            // Create new facility
            const createFacilityQuery = 'INSERT INTO facilities (name) VALUES ($1) RETURNING id';
            const createResult = await client.query(createFacilityQuery, [facilityName]);
            facilityId = createResult.rows[0].id;
            console.log(`🆕 Created new facility: ${facilityName} (ID: ${facilityId})`);
          } else {
            facilityId = facilityResult.rows[0].id;
            console.log(`📍 Found existing facility: ${facilityName} (ID: ${facilityId})`);
          }
          
          // Link facility to accommodation
          const linkQuery = 'INSERT INTO accommodation_facilities (accommodation_id, facility_id) VALUES ($1, $2)';
          await client.query(linkQuery, [accommodationId, facilityId]);
          console.log(`🔗 Linked facility ${facilityName} to accommodation`);
          
        } catch (facilityError) {
          console.error(`❌ Failed to process facility ${facilityName}:`, facilityError.message);
          // Continue with other facilities
        }
      }
    }
    
    await client.query('COMMIT');
    console.log('✅ Facilities updated successfully');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ UPDATE FACILITIES ERROR:', error.message);
    throw error;
  } finally {
    client.release();
  }
}

console.log('✅ ACCOMMODATION MODEL - Module loaded successfully');

module.exports = {
  createAccommodation,
  getAccommodations,
  getAccommodationById,
  updateAccommodation,
  updateAccommodationFacilities,
  deleteAccommodation,
  getAccommodationsByUserId
};
