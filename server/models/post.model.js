const { pool } = require("../config/connection");

async function getPosts(userId) {
  const peerQuery = `
    SELECT id FROM public.users 
       WHERE id != $1 
         AND university = (SELECT university FROM users WHERE id = $1)
         AND city = (SELECT city FROM users WHERE id = $1)
  `;
  const peerResult = await pool.query(peerQuery, [userId]);
  const peerIds = peerResult.rows.map((r) => r.id);
  const userAndPeers = [userId, ...peerIds];
  const postQuery = `
  SELECT p.id, p.content, p.images, p.created_at, p.likes, p.comments,
              p.is_liked, p.tags, p.post_type,
              u.id AS user_id, u.name AS user_name, u.image AS user_image, u.city AS user_location
       FROM posts p
       JOIN users u ON p.user_id = u.id
       WHERE p.user_id = ANY($1)
       ORDER BY p.created_at DESC
  `;
  const postResult = await pool.query(postQuery, [userAndPeers]);
  const posts = postResult.rows.map((p) => ({
    id: p.id,
    userId: p.user_id,
    userImage: p.user_image,
    userName: p.user_name,
    userLocation: p.user_location,
    timeAgo: new Date(p.created_at).toISOString(), // Flutter can format to "time ago"
    content: p.content,
    likes: p.likes || 0,
    comments: p.comments || 0,
    isLiked: p.is_liked || false,
    tags: p.tags || [],
    postType: p.post_type || "text",
    images: p.images || null,
  }));
  return posts;
}
async function likePost(postId) {
  const result = await pool.query(
    "UPDATE public.posts SET likes=likes+1, is_liked=true WHERE id=$1 RETURNING *",
    [postId]
  );
  return result.rows[0];
}
async function unlikePost(postId) {
  const result = await pool.query(
    `
    UPDATE public.posts 
    SET likes = GREATEST(likes - 1, 0), is_liked = false 
    WHERE id = $1 
    RETURNING *`,
    [postId]
  );
  return result.rows[0];
}
async function addPost(userId, data) {
  const { content, postType, tags, images } = data;

  const result = await pool.query(
    `INSERT INTO public.posts (user_id, content, images, tags, post_type, created_at, likes, comments) 
     VALUES ($1, $2, $3, $4, $5, NOW(), 0, 0)
     RETURNING id, content, images, tags, post_type, created_at`,
    [userId, content, images || null, tags || [], postType || "text"]
  );

  return result.rows[0];
}
async function userResult(userId) {
  const result = await pool.query(
    `SELECT id,name,image,city
  FROM public.users
  WHERE id=$1`,
    [userId]
  );
  return result.rows[0];
}
module.exports = {
  getPosts,
  likePost,
  unlikePost,
  addPost,
  userResult
};
