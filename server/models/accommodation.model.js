console.log('🔄 ACCOMMODATION MODEL - Starting module load...');

const { pool } = require('../config/connection');
console.log('✅ Database connection loaded');

// Create a new accommodation
async function createAccommodation(accommodationData) {
  console.log('\n🏠 ACCOMMODATION MODEL - createAccommodation called');
  console.log('📝 Data:', JSON.stringify(accommodationData, null, 2));
  
  const client = await pool.connect();
  
  try {
    const {
      user_id,
      title,
      location,
      rent,
      rent_period,
      contact_email,
      available_from,
      available_to,
      gender_preference,
      facilities,
      description,
      image_urls,
      is_roommate_request
    } = accommodationData;

    const query = `
      INSERT INTO accommodations (
        user_id, title, location, rent, rent_period, contact_email,
        available_from, available_to, gender_preference, facilities,
        description, image_urls, is_roommate_request, created_at, updated_at
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, NOW(), NOW()
      ) RETURNING *
    `;

    const values = [
      user_id,
      title,
      location,
      rent,
      rent_period || 'month',
      contact_email,
      available_from,
      available_to,
      gender_preference,
      JSON.stringify(facilities),
      description,
      image_urls || [],
      is_roommate_request || false
    ];

    console.log('📊 Executing query:', query);
    console.log('📊 Query values:', values);

    const result = await client.query(query, values);
    const accommodation = result.rows[0];
    
    console.log('✅ Accommodation created successfully:', accommodation.id);
    return accommodation;
    
  } catch (error) {
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
    let query = `
      SELECT 
        a.*,
        u.email as user_email,
        u.mobile as user_mobile
      FROM accommodations a
      LEFT JOIN users u ON a.user_id = u.id
      WHERE 1=1
    `;
    
    const values = [];
    let paramCount = 0;

    // Add filters
    if (filters.location) {
      paramCount++;
      query += ` AND LOWER(a.location) LIKE LOWER($${paramCount})`;
      values.push(`%${filters.location}%`);
    }

    if (filters.max_rent) {
      paramCount++;
      query += ` AND a.rent <= $${paramCount}`;
      values.push(filters.max_rent);
    }

    if (filters.min_rent) {
      paramCount++;
      query += ` AND a.rent >= $${paramCount}`;
      values.push(filters.min_rent);
    }

    if (filters.gender_preference) {
      paramCount++;
      query += ` AND a.gender_preference = $${paramCount}`;
      values.push(filters.gender_preference);
    }

    if (filters.is_roommate_request !== undefined) {
      paramCount++;
      query += ` AND a.is_roommate_request = $${paramCount}`;
      values.push(filters.is_roommate_request);
    }

    // Add pagination
    const limit = filters.limit || 20;
    const offset = filters.offset || 0;
    
    query += ` ORDER BY a.created_at DESC LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}`;
    values.push(limit, offset);

    console.log('📊 Executing query:', query);
    console.log('📊 Query values:', values);

    const result = await client.query(query, values);
    const accommodations = result.rows;
    
    console.log(`✅ Found ${accommodations.length} accommodations`);
    return accommodations;
    
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
      SELECT 
        a.*,
        u.email as user_email,
        u.mobile as user_mobile
      FROM accommodations a
      LEFT JOIN users u ON a.user_id = u.id
      WHERE a.id = $1
    `;

    const result = await client.query(query, [id]);
    const accommodation = result.rows[0];
    
    if (!accommodation) {
      console.log('❌ Accommodation not found');
      return null;
    }
    
    console.log('✅ Accommodation found:', accommodation.title);
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

    // Add updated_at
    paramCount++;
    fields.push(`updated_at = $${paramCount}`);
    values.push(new Date());

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
    const query = `
      SELECT * FROM accommodations 
      WHERE user_id = $1 
      ORDER BY created_at DESC
    `;

    const result = await client.query(query, [userId]);
    const accommodations = result.rows;
    
    console.log(`✅ Found ${accommodations.length} accommodations for user`);
    return accommodations;
    
  } catch (error) {
    console.error('❌ GET USER ACCOMMODATIONS ERROR:', error.message);
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
  deleteAccommodation,
  getAccommodationsByUserId
};
