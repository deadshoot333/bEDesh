require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/auth.routes');
const accommodationRoutes = require('./routes/accommodation.routes');

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

// Add a simple test route
app.get('/test', (req, res) => {
  res.json({ success: true, message: 'Server is working!' });
});

app.use('/auth', authRoutes);
app.use('/accommodations', accommodationRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Test endpoint: http://localhost:${PORT}/test`);
});
