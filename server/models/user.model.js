const { pool } = require("../config/connection.js");

async function findUserByEmail(email) {
  const result = await pool.query("SELECT * FROM users WHERE email = $1", [
    email,
  ]);
  return result.rows[0];
}

async function createUser(email, hashedPassword) {
  const result = await pool.query(
    "INSERT INTO users (email, password) VALUES ($1, $2) RETURNING id, email",
    [email, hashedPassword]
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
  const result = await pool.query("SELECT * FROM refresh_tokens WHERE token = $1",[refreshToken])
  return result
}

async function insertToken(token,userId) {
  const result = await pool.query(
    "INSERT INTO refresh_tokens (token, userId) VALUES ($1, $2)'", [token, userId]
  )
}

async function deleteToken(refreshToken) {
  await pool.query('DELETE FROM refresh_tokens WHERE token = $1', [refreshToken]);
}
module.exports = {
  findUserByEmail,
  createUser,
  findUserById,
  insertToken,
  getToken,
  deleteToken
};
