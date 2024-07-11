const express = require('express');
const {getClient} = require('../database');
const router = express.Router();

//Wine Partial-Match Search - Users can use multiple parameters to find their drinks
router.post('/searchWine', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {Name, Company, Style, Origin} = req.body


    let filter = {}
    if(Name){
        filter.Name = {$regex: Name, $options: 'i'}
    }
    if(Company){
        filter.Company = {$regex: Company, $options: 'i'}
    }
    if(Style){
        filter.Style = {$regex: Style, $options: 'i'}
    }
    if(Origin){
        filter.Origin = {$regex: Origin, $options: 'i'}
    }

    const wine = await db.collection('Wine').find(filter).toArray()
    
    if(win.length > 0){
        res.status(200).json({wine})
    }
    else{
        res.status(400).json({error:"No win matched with the criteria"})
    }
})



module.exports = router