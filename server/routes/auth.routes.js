const express = require('express');
const router = express.Router();
const authenticateToken = require('../middlewares/auth.middleware.js');
const { registerUser, loginUser, getProfile, verifyToken, generateAccessToken } = require('../services/auth.service.js');
const { getToken, deleteToken } = require('../models/user.model.js');

// Signup
router.post('/signup', async (req, res) => {
  console.log('\n🚀 SIGNUP ROUTE STARTED');
  console.log('📥 Request body:', JSON.stringify(req.body, null, 2));
  console.log('📋 Request headers:', JSON.stringify(req.headers, null, 2));
  
  const { name,email, mobile, password,university,city } = req.body;
  
  console.log('🔍 Extracted fields:');
  console.log('  - email:', email, '(type:', typeof email, ')');
  console.log('  - mobile:', mobile, '(type:', typeof mobile, ')');
  console.log('  - password:', password ? '[REDACTED]' : 'undefined', '(type:', typeof password, ')');
  
  // Validate required fields
  if (!email || !mobile || !password || !name) {
    console.log('❌ VALIDATION FAILED: Missing required fields');
    console.log('  - email present:', !!email);
    console.log('  - mobile present:', !!mobile);
    console.log('  - password present:', !!password);
    console.log('  - name present:', !!name);
    return res.status(400).json({ error: 'Name,Email, mobile, and password are required' });
  }
  
  // Basic email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.edu$/;
  if (!emailRegex.test(email)) {
    console.log('❌ VALIDATION FAILED: Only edu mails can be taken:', email);
    return res.status(400).json({ error: 'Only edu mails can be taken' });
  }
  
  // Password validation
  if (password.length < 6) {
    console.log('❌ VALIDATION FAILED: Password too short, length:', password.length);
    return res.status(400).json({ error: 'Password must be at least 6 characters long' });
  }
  
  console.log('✅ All validations passed, calling registerUser...');
  
  try {
    const user = await registerUser(name,email, mobile, password,university,city);
    console.log('✅ User created successfully:', user);
    res.status(201).json({ message: 'User created', user });
  } catch (err) {
    console.error('❌ SIGNUP ERROR in registerUser:');
    console.error('  - Error message:', err.message);
    console.error('  - Error stack:', err.stack);
    console.error('  - Error code:', err.code);
    res.status(400).json({ error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  console.log('Login request received:', req.body);
  const { email, password } = req.body;
  
  // Validate required fields
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }
  
  try {
    const {accessToken, refreshToken, user} = await loginUser(email, password);
    res.json({accessToken,
      refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        image: user.image,
        city: user.city,
        university:user.university
      }});
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(401).json({ error: err.message });
  }
});

// Protected route
router.get('/me', authenticateToken, async (req, res) => {
  console.log('\n🔍 PROFILE ENDPOINT - GET /auth/me called');
  console.log('🧑 req.user:', req.user);
  console.log('🆔 req.user.id:', req.user?.id);
  console.log('🆔 req.user.userId:', req.user?.userId);
  
  try {
    const userId = req.user.userId || req.user.id;
    console.log('🔎 Looking up user with ID:', userId);
    
    const user = await getProfile(userId);
    console.log('✅ Profile found:', user);
    
    res.json({ user });
  } catch (err) {
    console.error('❌ Profile error:', err.message);
    res.status(500).json({ error: 'Failed to get profile' });
  }
});
//Refresh Token
router.post('/refresh',async(req,res)=>{
  const {refreshToken} = req.body
  if(!refreshToken){
    return res.status(401).json({error:"Token not Found"})
  }
  try {
    const stored = await getToken(refreshToken)
    if(stored.rowCount == 0){
      return res.status(401).json({error:"No Token found in Database"})
    }
    const payload = verifyToken(refreshToken)
    const newAccessToken = generateAccessToken(payload.userId)
    res.json({ accessToken: newAccessToken });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
})
//Logout
router.delete('/logout',async(req,res)=>{
  try {
    const {refreshToken} = req.body 
    await deleteToken(refreshToken)
    res.json({'message':'Logged Out'})
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
})

module.exports = router;
