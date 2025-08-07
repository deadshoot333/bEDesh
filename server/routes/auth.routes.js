const express = require('express');
const router = express.Router();
const authenticateToken = require('../middlewares/auth.middleware.js');
const { registerUser, loginUser, getProfile, verifyToken, generateAccessToken } = require('../services/auth.service.js');
const { getToken, deleteToken } = require('../models/user.model.js');

// Signup
router.post('/signup', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await registerUser(email, password);
    res.status(201).json({ message: 'User created', user });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const {accessToken,refreshToken} = await loginUser(email, password);
    res.json({accessToken,refreshToken});
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
});

// Protected route
//TODO:Token not Inserting in DB
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
  const {refreshToken} = res.body
  if(!refreshToken){
    res.status(401).json({error:"Token not Found"})
  }
  const stored = await getToken(refreshToken)
  if(!stored.rowCount == 0){
    res.status(401).json({error:"No Token found in Database"})
  }
  const payload = verifyToken(refreshToken)
  const newAccessToken = generateAccessToken(payload.userId)
  res.json({ accessToken: newAccessToken });
})
//Logout
router.delete('/logout',async(req,res)=>{
  const {refreshToken} = req.body 
  const deleteToken = await deleteToken(refreshToken)
  res.json({'message':'Logged Out'})
})

module.exports = router;
