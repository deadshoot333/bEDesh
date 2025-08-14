const express = require("express")
const {
    getAllCountry
} = require("../models/country.model")

const router = express.Router()

router.get('/all-countries',async(req,res)=>{
    try {
        const countries = await getAllCountry();
        res.json({countries})
    } catch (error) {
        console.error('Error Fetching Countries: ',error)
         res.status(500).json({ error: 'Failed to fetch countries' });
    }
})

module.exports = router