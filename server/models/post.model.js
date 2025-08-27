const { pool } = require("../config/connection");

async function getAllPosts() {
  const result = await pool.query(
    "SELECT p.id, p.content, p.post_type, p.tags, p.images, p.likes, p.comments_count, p.is_liked, p.created_at, u.id AS user_id, u.name, u.image, u.city FROM public.posts p JOIN public.users u ON p.user_id = u.id ORDER BY p.created_at DESC"
  );
  return result.rows;
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
async function addPost(data) {
  const { userId, content, postType, tags, images } = data;

  const result = await pool.query(
    `INSERT INTO public.posts (user_id, content, post_type, tags, images) 
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [userId, content, postType, tags, images]
  );

  return result.rows[0];
}
module.exports = {
  getAllPosts,
  likePost,
  unlikePost,
  addPost
};
