const { pool } = require("../config/connection");

async function sentRequest(requesterId, receiverId) {
  const result = await pool.query(
    "INSERT INTO peer_connections (requester_id,receiver_id,status) VALUES ($1,$2,'pending') RETURNING id",
    [requesterId, receiverId]
  );
  return result.rows[0];
}
async function getUsersfromQuery(q){
 
  const { query } = q;
  const result = await pool.query(
    `SELECT id, name, image, city, university,
     FROM public.users
     WHERE name ILIKE $1 OR university ILIKE $1`,
    [`%${query}%`]
  );
  return result.rows;
}
async function respondRequest(connectionId, action) {
  const status = action === "accept" ? "accepted" : "rejected";
  const result = await pool.query(
    "UPDATE peer_connections SET status = $1 WHERE id = $2",
    [status, connectionId]
  );
  //   const message = `Request ${status}`
  return `Request ${status}`;
}

async function getPeersCity(city) {
  const result = await pool.query(
    "SELECT email FROM public.users WHERE city=$1",
    [city]
  );
  return result.rows;
}

async function getPeersUni(uni){
  const result = await pool.query(
    "SELECT email FROM public.users WHERE university=$1",
    [uni]
  );
  return result.rows;
}
module.exports = {
  sentRequest,
  respondRequest,
  getPeersCity,
  getPeersUni,
  getUsersfromQuery
};
