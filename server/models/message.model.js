const { pool } = require("../config/connection");

async function sendMessage(senderId, receiverId, content) {
  const result = await pool.query(
    "INSERT INTO public.messages (sender_id,receiver_id,content) VALUES ($1,$2,$3) RETURNING *",
    [senderId, receiverId, content]
  );
  return result.rows[0];
}

async function getMessages(userId, peerId) {
  const result = await pool.query(
    "SELECT m.*,u.name as sender_name,u.image as sender_image FROM public.messages m JOIN public.users u ON m.sender_id = u.id  WHERE (m.sender_id = $1 AND m.receiver_id = $2) OR (m.sender_id = $2 AND m.receiver_id = $1) ORDER BY m.created_at ASC",
    [userId, peerId]
  );
  return result.rows;
}
module.exports = { sendMessage, getMessages };
