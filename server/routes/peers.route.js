const express = require("express");
const { sentRequest, respondRequest } = require("../models/peers.model");
const router = express.Router();

router.post("/connect", async (req, res) => {
  const { requesterId, receiverId } = req.body;
  try {
    const connection = await sentRequest(requesterId, receiverId);
    res.json({ connection });
  } catch (error) {
    console.error("Error sending connections:", error);
    res.status(500).json({ error: "Failed to sent connections" });
  }
});

router.post("/respond", async (req, res) => {
  const { connectionId, action } = req.body;
  try {
    const respond = await respondRequest(connectionId, action);
    res.json({ message: respond });
  } catch (error) {
     res.status(500).json({ error: "Failed to respond to request" });
  }
});

module.exports = router;
