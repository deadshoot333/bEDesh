const { pool } = require("../config/connection.js");

async function findUserByEmail(email) {
  console.log("\n🗄️  DATABASE - findUserByEmail called with:", email);
  try {
    const result = await pool.query(
      "SELECT * FROM public.users WHERE email = $1",
      [email]
    );
    console.log("📊 Query result - rows found:", result.rows.length);
    return result.rows[0];
  } catch (error) {
    console.error("❌ DATABASE ERROR in findUserByEmail:", error.message);
    throw error;
  }
}

async function findUserByMobile(mobile) {
  console.log("\n🗄️  DATABASE - findUserByMobile called with:", mobile);
  try {
    const result = await pool.query(
      "SELECT * FROM public.users WHERE mobile_number = $1",
      [mobile]
    );
    console.log("📊 Query result - rows found:", result.rows.length);
    return result.rows[0];
  } catch (error) {
    console.error("❌ DATABASE ERROR in findUserByMobile:", error.message);
    throw error;
  }
}

async function createUser(email, mobile, hashedPassword, university, city) {
  console.log("\n🗄️  DATABASE - createUser called");
  console.log("📝 Parameters:");
  console.log("  - email:", email);
  console.log("  - mobile:", mobile);
  console.log(
    "  - hashedPassword:",
    hashedPassword ? "[REDACTED]" : "undefined"
  );
  console.log("  - university:", university);
  console.log("  - city", city);

  try {
    console.log("💾 Executing INSERT query...");
    const result = await pool.query(
      "INSERT INTO public.users (email, mobile_number, password,university,city) VALUES ($1, $2, $3, $4, $5) RETURNING id, email,university,city",
      [email, mobile, hashedPassword,university,city]
    );
    console.log("✅ User inserted successfully:", result.rows[0]);
    return result.rows[0];
  } catch (error) {
    console.error("❌ DATABASE ERROR in createUser:");
    console.error("  - Error code:", error.code);
    console.error("  - Error message:", error.message);
    console.error("  - Error detail:", error.detail);
    console.error("  - Error constraint:", error.constraint);
    throw error;
  }
}

async function findUserById(id) {
  console.log("\n🗄️  DATABASE - findUserById called with:", id);
  try {
    const result = await pool.query(
      "SELECT id, email FROM public.users WHERE id = $1",
      [id]
    );
    console.log("📊 Query result - rows found:", result.rows.length);
    return result.rows[0];
  } catch (error) {
    console.error("❌ DATABASE ERROR in findUserById:", error.message);
    throw error;
  }
}

async function getToken(refreshToken) {
  console.log("\n🗄️  DATABASE - getToken called with token");
  try {
    const result = await pool.query(
      "SELECT * FROM public.rf_tokens WHERE token = $1",
      [refreshToken]
    );
    console.log("📊 Token query result - rows found:", result.rows.length);
    return result;
  } catch (error) {
    console.error("❌ DATABASE ERROR in getToken:", error.message);
    throw error;
  }
}

async function insertToken(token, userId) {
  console.log("\n🗄️  DATABASE - insertToken called");
  console.log("📝 Parameters:");
  console.log("  - userId:", userId);
  console.log("  - token:", token ? "[REDACTED]" : "undefined");

  try {
    const result = await pool.query(
      "INSERT INTO public.rf_tokens (token, user_id) VALUES ($1, $2)",
      [token, userId]
    );
    console.log("✅ Token inserted successfully");
    return result;
  } catch (error) {
    console.error("❌ DATABASE ERROR in insertToken:");
    console.error("  - Error code:", error.code);
    console.error("  - Error message:", error.message);
    console.error("  - Error detail:", error.detail);
    throw error;
  }
}

async function deleteToken(refreshToken) {
  console.log("\n🗄️  DATABASE - deleteToken called");
  try {
    await pool.query("DELETE FROM public.rf_tokens WHERE token = $1", [
      refreshToken,
    ]);
    console.log("✅ Token deleted successfully");
  } catch (error) {
    console.error("❌ DATABASE ERROR in deleteToken:", error.message);
    throw error;
  }
}
module.exports = {
  findUserByEmail,
  findUserByMobile,
  createUser,
  findUserById,
  insertToken,
  getToken,
  deleteToken,
};
