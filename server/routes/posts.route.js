const express = require("express");
const { getAllPosts, addPost } = require("../models/post.model");
const router = express.Router();

router.get("/get-posts", async (req, res) => {
  const { user_id } = req.body;
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

module.exports = router;
