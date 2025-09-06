const express = require("express");
const {
  sentRequest,
  respondRequest,
  getPeersCity,
  getPeersUni,
  getUsersfromQuery,
} = require("../models/peers.model");
const { findUserById } = require("../models/user.model");
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
router.get("/city/:id", async (req, res) => {
  const { id } = req.body;
  const user = await findUserById(id);
  console.log(user)
  const city = user.city;
  try {
    const peersCity = await getPeersCity(city);
    res.json({ peersCity });
  } catch (error) {
    res.status(500).json({ error: "Failed to get peers of same city" });
  }
});
router.get("/university/:id", async (req, res) => {
  const { id } = req.body;
  const user = await findUserById(id);
  console.log(user)
  const university = user.university;
  try {
    const peersUni = await getPeersUni(university);
    res.json({ peersUni });
  } catch (error) {
    res.status(500).json({ error: "Failed to get peers of same university" });
  }
});
module.exports = router;
