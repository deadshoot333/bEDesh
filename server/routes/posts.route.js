const express = require("express");
const { getAllPosts, addPost, getUserPostsCount } = require("../models/post.model");
const authenticateToken = require('../middlewares/auth.middleware.js');
const router = express.Router();

router.get("/get-posts", async (req, res) => {
  const { user_id } = req.query;
  try {
    const posts = await getAllPosts(user_id);
    res.json({ posts });
  } catch (error) {
    console.error("Error gettting posts:", error);
    res.status(500).json({ error: "Failed to get posts" });
  }
});

router.post("/post", async (req, res) => {
  try {
    const post = await addPost(req.body);
    res.json({ post });
  } catch (error) {
    console.error("Error gettting posts:", error);
    res.status(500).json({ error: "Failed to get posts" });
  }
});

// Get user posts count
router.get("/user/:userId/posts/count", authenticateToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const count = await getUserPostsCount(userId);
    res.json({ count });
  } catch (error) {
    console.error("Error getting user posts count:", error);
    res.status(500).json({ error: "Failed to get posts count" });
  }
});

module.exports = router;
