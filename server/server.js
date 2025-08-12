require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const uniRoutes = require('./routes/university.route')
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

app.use('/auth', authRoutes);
app.use("/university",uniRoutes)
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
