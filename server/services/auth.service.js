const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const {
  findUserByEmail,
  findUserByMobile,
  createUser,
  findUserById,
  insertToken,
} = require("../models/user.model.js");
require("dotenv").config();

const JWT_SECRET = process.env.JWT_SECRET;

async function registerUser(email, mobile, password) {
  const existingUser = await findUserByEmail(email);
  const existingUserMobile = await findUserByMobile(mobile);
  if (existingUser) throw new Error("User already exists");
  if (existingUserMobile) throw new Error("Mobile number already used");
  const hashedPassword = await bcrypt.hash(password, 10);
  return await createUser(email,mobile, hashedPassword);
}

async function loginUser(email, password) {
  const user = await findUserByEmail(email);
  if (!user || !(await bcrypt.compare(password, user.password))) {
    throw new Error("Invalid credentials");
  }

  // const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '1d' });
  accessToken = generateAccessToken(user.id);
  refreshToken = generateRefreshToken(user.id);
  await insertToken(refreshToken, user.id);
  return { accessToken, refreshToken };
}

async function getProfile(userId) {
  return await findUserById(userId);
}

function generateAccessToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRES_IN,
  });
}

function generateRefreshToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN,
  });
}

function verifyToken(refreshToken) {
  const payload = jwt.verify(refreshToken, JWT_SECRET);
  return payload;
}

module.exports = {
  registerUser,
  loginUser,
  getProfile,
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
};
