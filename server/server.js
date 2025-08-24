require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const uniRoutes = require('./routes/university.route');
const countryRoutes = require('./routes/country.route');
const peerRoutes = require('./routes/peers.route')
const communityRoutes = require("./routes/posts.route")
const app = express();

// Debug middleware - log all incoming requests
app.use((req, res, next) => {
  console.log('\n🔍 INCOMING REQUEST:');
  console.log('Method:', req.method);
  console.log('URL:', req.url);
  console.log('Headers:', JSON.stringify(req.headers, null, 2));
  console.log('Body:', req.body);
  console.log('Raw Body Length:', req.get('content-length') || 'unknown');
  next();
});

app.use(cors());
app.use(express.json());
app.get("/",async (req,res) =>{
  res.send("Welcome to bEDesh Server")
})
app.use('/auth', authRoutes);
app.use("/api/university", uniRoutes)
app.use("/api/country",countryRoutes)
app.use("/api/peer",peerRoutes)
app.use("/api/community",communityRoutes)
const PORT = process.env.PORT || 3000;
app.listen(PORT,"0.0.0.0", () => console.log(`Server running on port ${PORT}`));
