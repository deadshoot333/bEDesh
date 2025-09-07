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
  
  const { email, mobile, password,university,city } = req.body;
  
  console.log('🔍 Extracted fields:');
  console.log('  - email:', email, '(type:', typeof email, ')');
  console.log('  - mobile:', mobile, '(type:', typeof mobile, ')');
  console.log('  - password:', password ? '[REDACTED]' : 'undefined', '(type:', typeof password, ')');
  
  // Validate required fields
  if (!email || !mobile || !password) {
    console.log('❌ VALIDATION FAILED: Missing required fields');
    console.log('  - email present:', !!email);
    console.log('  - mobile present:', !!mobile);
    console.log('  - password present:', !!password);
    return res.status(400).json({ error: 'Email, mobile, and password are required' });
  }
  
  // Basic email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    console.log('❌ VALIDATION FAILED: Invalid email format:', email);
    return res.status(400).json({ error: 'Invalid email format' });
  }
  
  // Password validation
  if (password.length < 6) {
    console.log('❌ VALIDATION FAILED: Password too short, length:', password.length);
    return res.status(400).json({ error: 'Password must be at least 6 characters long' });
  }
  
  console.log('✅ All validations passed, calling registerUser...');
  
  try {
    const user = await registerUser(email, mobile, password,university,city);
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
    const {accessToken,refreshToken} = await loginUser(email, password);
    res.json({accessToken,refreshToken});
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(401).json({ error: err.message });
  }
});

// Protected route
router.get('/me', authenticateToken, async (req, res) => {
  try {
    const user = await getProfile(req.user.id);
    res.json({ user });
  } catch (err) {
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

// Get sample users for testing (DEV ONLY)
router.get('/test-users', async (req, res) => {
  try {
    const { pool } = require('../config/connection');
    const result = await pool.query('SELECT id, email, university FROM public.users LIMIT 5');
    res.json({ 
      message: 'Sample users for testing',
      users: result.rows 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
