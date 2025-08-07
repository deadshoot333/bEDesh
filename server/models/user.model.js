const { pool } = require("../config/connection.js");

async function findUserByEmail(email) {
  const result = await pool.query("SELECT * FROM users WHERE email = $1", [
    email,
  ]);
  return result.rows[0];
}

async function findUserByMobile(mobile) {
  const result = await pool.query("SELECT * FROM users WHERE mobile_number = $1", [
    mobile,
  ]);
  return result.rows[0];
}

async function createUser(email,mobile, hashedPassword) {
  const result = await pool.query(
    "INSERT INTO users (email,mobile_number, password) VALUES ($1, $2, $3) RETURNING id, email",
    [email,mobile, hashedPassword]
  );
  return result.rows[0];
}

async function findUserById(id) {
  const result = await pool.query("SELECT id, email FROM users WHERE id = $1", [
    id,
  ]);
  return result.rows[0];
}

async function getToken(refreshToken) {
  const result = await pool.query("SELECT * FROM rf_tokens WHERE token = $1",[refreshToken])
  return result
}

async function insertToken(token,userId) {
  const result = await pool.query(
    "INSERT INTO rf_tokens (token, user_id) VALUES ($1, $2)", [token, userId]
  )
}

async function deleteToken(refreshToken) {
  await pool.query('DELETE FROM rf_tokens WHERE token = $1', [refreshToken]);
}
module.exports = {
  findUserByEmail,
  findUserByMobile,
  createUser,
  findUserById,
  insertToken,
  getToken,
  deleteToken
};
