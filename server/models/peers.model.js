const { pool } = require("../config/connection");

async function getUsersfromQuery(q) {
  const { query } = q;
  const result = await pool.query(
    `SELECT id, name, image, city, university,
    FROM public.users
    WHERE name ILIKE $1 OR university ILIKE $1`,
    [`%${query}%`]
  );
  return result.rows;
}
async function sentRequest(requesterId, receiverId) {
  const result = await pool.query(
    "INSERT INTO peer_connections (requester_id,receiver_id,status) VALUES ($1,$2,'pending') RETURNING id",
    [requesterId, receiverId]
  );
  return result.rows[0];
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
async function listReceived(userId) {
  const result = await pool.query(
    `SELECT pc.id as connection_id,
            pc.status,
            pc.created_at,
            u.id, u.name, u.university, u.city
     FROM peer_connections pc
     JOIN public.users u ON u.id = pc.requester_id
     WHERE pc.receiver_id=$1
     ORDER BY (pc.status='pending') DESC, pc.created_at DESC`,
    [userId]
  );
  return result.rows;
}
async function listSent(userId) {
  const result = await pool.query(
    `SELECT pc.id as connection_id,
            pc.status,
            pc.created_at,
            u.id, u.name, u.university, u.city
     FROM peer_connections pc
     JOIN public.users u ON u.id = pc.receiver_id
     WHERE pc.requester_id=$1
     ORDER BY (pc.status='pending') DESC, pc.created_at DESC`,
    [userId]
  );
  return result.rows;
}
async function getPeersCity(city, id) {
  const result = await pool.query(
    "SELECT * FROM public.users WHERE city=$1 AND id!=$2",
    [city, id]
  );
  return result.rows;
}

async function getPeersUni(uni, id) {
  const result = await pool.query(
    "SELECT * FROM public.users WHERE university=$1 AND id!=$2",
    [uni, id]
  );
  return result.rows;
}

async function getUserConnectionsCount(userId) {
  const result = await pool.query(
    `SELECT COUNT(*) as count 
     FROM peer_connections 
     WHERE (requester_id = $1 OR receiver_id = $1) 
     AND status = 'accepted'`,
    [userId]
  );
  return parseInt(result.rows[0].count) || 0;
}

async function getUserConnections(userId) {
  const result = await pool.query(
    `SELECT pc.id as connection_id,
            pc.status,
            pc.created_at,
            CASE 
              WHEN pc.requester_id = $1 THEN receiver.id
              ELSE requester.id
            END as user_id,
            CASE 
              WHEN pc.requester_id = $1 THEN receiver.name
              ELSE requester.name
            END as name,
            CASE 
              WHEN pc.requester_id = $1 THEN receiver.email
              ELSE requester.email
            END as email,
            CASE 
              WHEN pc.requester_id = $1 THEN receiver.university
              ELSE requester.university
            END as university,
            CASE 
              WHEN pc.requester_id = $1 THEN receiver.city
              ELSE requester.city
            END as city
     FROM peer_connections pc
     JOIN public.users requester ON requester.id = pc.requester_id
     JOIN public.users receiver ON receiver.id = pc.receiver_id
     WHERE (pc.requester_id = $1 OR pc.receiver_id = $1)
     AND pc.status = 'accepted'
     ORDER BY pc.created_at DESC`,
    [userId]
  );
  return result.rows;
}

async function disconnectUsers(connectionId) {
  const result = await pool.query(
    "DELETE FROM peer_connections WHERE id = $1",
    [connectionId]
  );
  return result.rowCount > 0;
}

module.exports = {
  sentRequest,
  respondRequest,
  getPeersCity,
  getPeersUni,
  getUsersfromQuery,
  listReceived,
  listSent,
  getUserConnectionsCount,
  getUserConnections,
  disconnectUsers,
};
