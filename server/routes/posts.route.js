const express = require("express");
const { getPosts, addPost, userResult } = require("../models/post.model");
const authenticateToken = require("../middlewares/auth.middleware.js");
const router = express.Router();

router.get("/get-posts", authenticateToken, async (req, res) => {
  const user_id  = req.user.id;
  try {
    const posts = await getPosts(user_id);
    res.json({ posts });
  } catch (error) {
    console.error("Error gettting posts:", error);
    res.status(500).json({ error: "Failed to get posts" });
  }
});
router.post("/post", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const newPost = await addPost(userId, req.body);
    const user = userResult(userId);
    const formattedPost = {
      id: newPost.id,
      userId: user.id,
      userImage: user.image,
      userName: user.name,
      userLocation: user.city,
      timeAgo: new Date(newPost.created_at).toISOString(),
      content: newPost.content,
      likes: 0,
      comments: 0,
      isLiked: false,
      tags: newPost.tags || [],
      postType: newPost.post_type,
      images: newPost.images || null,
    };
    res.json({ formattedPost });
  } catch (error) {
    console.error("Error gettting posts:", error);
    res.status(500).json({ error: "Failed to get posts" });
  }
});

module.exports = router;
