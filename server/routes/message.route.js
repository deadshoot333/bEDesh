const express = require("express");
const { sendMessage, getMessages } = require("../models/message.model");

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const { senderId, receiverId, content } = req.body;
    if (!senderId || !receiverId || !content) {
      return res.status(400).json({ error: "Missing required Fields" });
    }
    const message = await sendMessage(senderId, receiverId, content);
    res.json(message);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get("/:userId/:peerId", async (req, res) => {
  try {
    const { userId, peerId } = req.params;
    const messages = await getMessages(userId, peerId);
    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
