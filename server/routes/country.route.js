const express = require("express")
const {
    getAllCountry,
    getCountryByName
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

router.get('/by-name/:name',async(req,res)=>{
    try{
    const {name} = req.params
    const country = await getCountryByName(decodeURIComponent(name));
    if(!country){
        return res.status(404).json({ error: 'Country not found' });
    }
    res.json(country)
    }
    catch(error)
    {
        res.status(500).json({ error: 'Failed to fetch countries' }); 
    }
})
module.exports = router