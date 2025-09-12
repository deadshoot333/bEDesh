const express = require("express");
const {
  sentRequest,
  respondRequest,
  getPeersCity,
  getPeersUni,
  getUsersfromQuery,
  listReceived,
  listSent,
} = require("../models/peers.model");
const { findUserById } = require("../models/user.model");
const authenticateToken = require("../middlewares/auth.middleware.js");
const router = express.Router();

router.get("/", async (req, res) => {
  const { query } = req.query;
  try {
    const result = await getUsersfromQuery(query);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: "Failed to get peers" });
  }
});
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
router.get("/requests/received/:userId", async (req, res) => {
  const { userId } = req.params;
  try {
    const rows = await listReceived(userId);
    return res.json(rows);
  } catch (error) {
    console.error("received error:", err);
    return res.status(500).json({ error: "Failed to fetch received requests" });
  }
});
router.get("/requests/sent/:userId", async (req, res) => {
  const { userId } = req.params;
  try {
    const rows = await listSent(userId);
    return res.json(rows);
  } catch (error) {
    console.error("sent error:", err);
    return res.status(500).json({ error: "Failed to fetch sent requests" });
  }
});
router.get("/city/:id", authenticateToken, async (req, res) => {
  const { id } = req.params;
  const user = await findUserById(id);
  console.log(user);
  const city = user.city;
  try {
    const peersCity = await getPeersCity(city,id);
    res.json(peersCity);
  } catch (error) {
    res.status(500).json({ error: "Failed to get peers of same city" });
  }
});
router.get("/university/:id", authenticateToken, async (req, res) => {
  const { id } = req.params;
  const user = await findUserById(id);
  console.log(user);
  const university = user.university;
  try {
    const peersUni = await getPeersUni(university,id);
    res.json(peersUni);
  } catch (error) {
    res.status(500).json({ error: "Failed to get peers of same university" });
  }
});
module.exports = router;
