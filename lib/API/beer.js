const express = require('express');
const {getClient} = require('../database');
const ObjectId = require('mongodb').ObjectId;
const router = express.Router();

//Beer Partial-Match Search - Users can use multiple parameters to find their drinks
router.post('/searchBeer', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {Name, Company, Style, Origin} = req.body

    let filter = {}
    if(Name){
        // filter.Name = {$regex: Name, $options: 'i'}
        const escapedName = Name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        filter.Name = { $regex: escapedName, $options: 'i' };
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

    const beer = await db.collection('Beer').find(filter).toArray();
    
    if(beer.length > 0){
        res.status(200).json({beer})
    }
    else{
        res.status(400).json({error:"No beers matched with the criteria"})
    }
})

//Retrieves all Beers in the database
router.get('/getAllBeers', async (req, res) => {
    const db = getClient().db('AlcoholDatabase'); // Replace with your database name
    const beers = await db.collection('Beer').find({}).toArray();

    if(beers.length > 0){
        res.status(200).json({beers})
    }
    else{
        res.status(400).json({error:"Couldn't retrieve all beers..."})
    }
});

//User can favorite Beer by adding UserId to the Drink's Favorite array
router.post('/favoriteBeer', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {_id, UserId} = req.body
    const BeerId = ObjectId.createFromHexString(_id)
    const favorite = await db.collection('Beer').updateOne( //Adds User Id to array
        { _id: BeerId },
        { $addToSet: { Favorites: UserId } }) // to avoid duplicates

    if (favorite.modifiedCount > 0) {
        res.status(200).json({favorite, message:"User has favorited their beer"})
    }
    else{
        res.status(400).json({message:"User could not favorite their beer"})
    }
})

//User can unfavorite Beer by deleting UserId from the Drink's Favorite array
router.post('/unfavoriteBeer', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {_id, UserId} = req.body
    const BeerId = ObjectId.createFromHexString(_id)

    const unfavorite = await db.collection('Beer').updateOne(
        { _id: BeerId }, 
        { $pull: { Favorites: UserId } }); //Removes UserId from array

    if (unfavorite.modifiedCount > 0) {
        res.status(200).json({unfavorite, message:"User has unfavorited their beer"})
    }
    else{
        res.status(400).json({message:"User could not unfavorite their beer"})
    }
})

//User can comment and add a star rating. The rating, comment, and User Id gets added to array.
router.post('/rateBeer', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {_id, UserId, Stars, Comment} = req.body
    const BeerId = ObjectId.createFromHexString(_id)

    const updateRating = await db.collection('Beer').updateOne(  //Checks if User already rated beer. If rating already exists, the rating gets updated.
        { _id: BeerId, 'Ratings.UserId': UserId },
        { $set: { 'Ratings.$.Rating': Stars, 'Ratings.$.Comment': Comment } }
    );

    if(updateRating.matchedCount === 0) { //If user has not rated the beer, it adds the User Id with their rating into the Ratings array.
        const addRating = await db.collection('Beer').updateOne(
            { _id: BeerId },
            { $push: { Ratings: { UserId: UserId, Rating: Stars, Comment: Comment } } }
        )
        res.status(200).json({addRating, message:"User has added their rating."})
    }
    else{
        res.status(200).json({updateRating, message:"User has updated their rating."})
    }
})

//Averages the total ratings users have given for a Beer
router.get('/beerRatings', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const { _id } = req.query;
    const BeerId = ObjectId.createFromHexString(_id)

    const result = await db.collection('Beer').aggregate([ //Using MongoDB aggregation, able to filter document to avg and only display ratings.
        {$match: {_id: BeerId}},
        { $project: { 
            _id: 1, 
            avgRating: { 
                $cond: { 
                    if: { $gt: [{ $size: "$Ratings" }, 0] }, 
                    then: { $avg: "$Ratings.Rating" }, 
                    else: 0 
                } 
            } 
        }}
    ]).toArray()

    if(result.length > 0){
        const avgRating = result[0].avgRating
        res.status(200).json({avgRating, message:"Beer's average rating has been calculated."})
    }
    else{
        res.status(400).json({message:"Average rating could not be retrieved."})
    }
})

router.get('/getBeerComments', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { _id } = req.query; // Use req.query to get the parameter from the query string
    const BeerId = ObjectId.createFromHexString(_id);

    // const beer = await db.collection('Beer').findOne({ _id: BeerId });
    const result = await db.collection('Beer').aggregate([
        { $match: { _id: BeerId } },
        {
            $project: {
                _id: 1,
                comments: {
                    $cond: {
                        if: { $gt: [{ $size: "$Ratings" }, 0] },
                        then: "$Ratings",
                        else: []
                    }
                }
            }
        }
    ]).toArray();

    if (result.length > 0) {
        // res.status(200).json({ comments: beer.Ratings });
        const comments = result[0].comments;
        res.status(200).json({ comments });
    } else {
        res.status(400).json({ message: "Comments could not be retrieved." });
    }
});

module.exports = router
