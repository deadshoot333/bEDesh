console.log('🔄 AUTH SERVICE - Starting module load...');

const bcrypt = require("bcryptjs");
console.log('✅ bcryptjs loaded');

const jwt = require("jsonwebtoken");
console.log('✅ jsonwebtoken loaded');

const {
  findUserByEmail,
  findUserByMobile,
  createUser,
  findUserById,
  insertToken,
} = require("../models/user.model.js");
console.log('✅ user.model.js loaded');

console.log('🔧 Loading environment variables...');
require("dotenv").config({ path: require('path').join(__dirname, '../.env') });
console.log('✅ dotenv config loaded');

const JWT_SECRET = process.env.JWT_SECRET;
console.log('🔑 JWT_SECRET check:', JWT_SECRET ? 'PRESENT' : 'MISSING');

if (!JWT_SECRET) {
  console.error("❌ JWT_SECRET environment variable is required");
  process.exit(1);
}
console.log('✅ JWT_SECRET validated, continuing...');

async function registerUser(email, mobile, password,university,city) {
  console.log('\n🔧 AUTH SERVICE - registerUser called');
  console.log('📝 Parameters:');
  console.log('  - email:', email);
  console.log('  - mobile:', mobile);
  console.log('  - password:', password ? '[REDACTED]' : 'undefined');
  console.log('  - university:',university)
  console.log('  - city',city)
  
  try {
    console.log('🔍 Checking if user exists by email...');
    const existingUser = await findUserByEmail(email);
    console.log('📧 Email check result:', existingUser ? 'USER EXISTS' : 'EMAIL AVAILABLE');
    
    console.log('🔍 Checking if mobile exists...');
    const existingUserMobile = await findUserByMobile(mobile);
    console.log('📱 Mobile check result:', existingUserMobile ? 'MOBILE EXISTS' : 'MOBILE AVAILABLE');
    
    if (existingUser) {
      console.log('❌ User registration failed: Email already exists');
      throw new Error("User already exists");
    }
    if (existingUserMobile) {
      console.log('❌ User registration failed: Mobile already used');
      throw new Error("Mobile number already used");
    }
    
    console.log('🔐 Hashing password...');
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('✅ Password hashed successfully');
    
    console.log('💾 Creating user in database...');
    const result = await createUser(email, mobile, hashedPassword,university,city);
    console.log('✅ User created successfully:', result);
    
    return result;
  } catch (error) {
    console.error('❌ ERROR in registerUser:');
    console.error('  - Error message:', error.message);
    console.error('  - Error stack:', error.stack);
    throw error;
  }
}

async function loginUser(email, password) {
  console.log('\n🔧 AUTH SERVICE - loginUser called');
  console.log('📝 Parameters:');
  console.log('  - email:', email);
  console.log('  - password:', password ? '[REDACTED]' : 'undefined');
  
  try {
    console.log('🔍 Finding user by email...');
    const user = await findUserByEmail(email);
    console.log('👤 User found:', user ? 'YES' : 'NO');
    
    if (!user) {
      console.log('❌ Login failed: User not found');
      throw new Error("Invalid credentials");
    }
    
    console.log('🔐 Comparing password...');
    const passwordMatch = await bcrypt.compare(password, user.password);
    console.log('🔑 Password match:', passwordMatch ? 'YES' : 'NO');
    
    if (!passwordMatch) {
      console.log('❌ Login failed: Invalid password');
      throw new Error("Invalid credentials");
    }
    
    console.log('🎫 Generating tokens...');
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);
    console.log('✅ Tokens generated successfully');
    
    console.log('💾 Storing refresh token...');
    await insertToken(refreshToken, user.id);
    console.log('✅ Refresh token stored');
    
    return { accessToken, refreshToken };
  } catch (error) {
    console.error('❌ ERROR in loginUser:');
    console.error('  - Error message:', error.message);
    console.error('  - Error stack:', error.stack);
    throw error;
  }
}

async function getProfile(userId) {
  console.log('\n🔧 AUTH SERVICE - getProfile called');
  console.log('📝 User ID:', userId);
  
  try {
    const user = await findUserById(userId);
    console.log('👤 User profile found:', user ? 'YES' : 'NO');
    return user;
  } catch (error) {
    console.error('❌ ERROR in getProfile:');
    console.error('  - Error message:', error.message);
    throw error;
  }
}

function generateAccessToken(userId) {
  console.log('🎫 Generating access token for user ID:', userId);
  try {
    const token = jwt.sign({ userId }, JWT_SECRET, {
      expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
    });
    console.log('✅ Access token generated successfully');
    return token;
  } catch (error) {
    console.error('❌ ERROR generating access token:', error.message);
    throw error;
  }
}

function generateRefreshToken(userId) {
  console.log('🎫 Generating refresh token for user ID:', userId);
  try {
    const token = jwt.sign({ userId }, JWT_SECRET, {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
    });
    console.log('✅ Refresh token generated successfully');
    return token;
  } catch (error) {
    console.error('❌ ERROR generating refresh token:', error.message);
    throw error;
  }
}

function verifyToken(refreshToken) {
  console.log('🔍 Verifying refresh token...');
  try {
    const payload = jwt.verify(refreshToken, JWT_SECRET);
    console.log('✅ Token verified successfully, user ID:', payload.userId);
    return payload;
  } catch (error) {
    console.error('❌ ERROR verifying token:', error.message);
    throw error;
  }
}

module.exports = {
  registerUser,
  loginUser,
  getProfile,
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
};
