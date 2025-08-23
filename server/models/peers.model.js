const { pool } = require("../config/connection");

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
  return `Request ${status}`
}
module.exports = {
  sentRequest,
  respondRequest
};
