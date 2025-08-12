const express = require('express');
const { getAllUniversity } = require('../models/university.model');
const router = express.Router();


router.get('all-uni',async(req,res)=>{
    const uni = await getAllUniversity()
    res.json({uni})
})

module.exports = router