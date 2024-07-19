const express = require('express');
const {getClient} = require('../database');
const ObjectId = require('mongodb').ObjectId;
const router = express.Router();

//Liquor Partial-Match Search - Users can use multiple parameters to find their drinks
router.post('/searchLiquor', async(req, res) => {
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

    const liquor = await db.collection('Liquor').find(filter).toArray()
    
    if(liquor.length > 0){
        res.status(200).json({liquor})
    }
    else{
        res.status(400).json({error:"No liquor matched with the criteria"})
    }
})

//Retrieves all Liquors in the database
router.get('/getAllLiquors', async (req, res) => {
    const db = getClient().db('AlcoholDatabase'); 
    const liquors = await db.collection('Liquor').find({}).toArray();

    if(liquors.length > 0){
        res.status(200).json({liquors})
    }
    else{
        res.status(400).json({error:"Couldn't retrieve all liquors..."})
    }
});

//User can favorite Liquors by adding UserId to the Drink's Favorite array
router.post('/favoriteLiquor', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {_id, UserId} = req.body
    const LiquorId = ObjectId.createFromHexString(_id)
    const favorite = await db.collection('Liquor').updateOne( //Adds User Id to array
        { _id: LiquorId },
        { $addToSet: { Favorites: UserId } }) // to avoid duplicates

    if (favorite.modifiedCount > 0) {
        res.status(200).json({favorite, message:"User has favorited their liquor"})
    }
    else{
        res.status(400).json({message:"User could not favorite their liquor"})
    }
})

//User can unfavorite Liquor by deleting UserId from the Drink's Favorite array
router.post('/unfavoriteLiquor', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {_id, UserId} = req.body
    const LiquorId = ObjectId.createFromHexString(_id)
    const unfavorite = await db.collection('Liquor').updateOne(
        {_id: LiquorId}, 
        {$pull: {Favorites: UserId,}}) //Removes UserId from array

    if (unfavorite.modifiedCount > 0) {
        res.status(200).json({unfavorite, message:"User has unfavorited their liquor"})
    }
    else{
        res.status(400).json({message:"User could not unfavorite their liquor"})
    }
})

//User can comment and add a star rating. The rating, comment, and User Id gets added to array.
router.post('/rateLiquor', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {_id, UserId, Stars, Comment} = req.body
    const LiquorId = ObjectId.createFromHexString(_id)

    const updateRating = await db.collection('Liquor').updateOne(  //Checks if User already rated liquor. If rating already exists, the rating gets updated.
        { _id: LiquorId, 'Ratings.UserId': UserId },
        { $set: { 'Ratings.$.Rating': Stars, 'Ratings.$.Comment': Comment } }
    );

    if(updateRating.matchedCount === 0) { //If user has not rated the liquor, it adds the User Id with their rating into the Ratings array.
        const addRating = await db.collection('Liquor').updateOne(
            { _id: LiquorId },
            { $push: { Ratings: { UserId: UserId, Rating: Stars, Comment: Comment } } }
        )
        res.status(200).json({addRating, message:"User has added their rating."})
    }
    else{
        res.status(200).json({updateRating, message:"User has updated their rating."})
    }
})

//Averages the total ratings users have given for a Liquor
router.get('/liquorRatings', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const { _id } = req.query;
    const LiquorId = ObjectId.createFromHexString(_id)

    const result = await db.collection('Liquor').aggregate([ //Using MongoDB aggregation, able to filter document to avg and only display ratings.
        {$match: {_id: LiquorId}},
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
        res.status(200).json({avgRating, message:"Liquor's average rating has been calculated."})
    }
    else{
        res.status(400).json({message:"Average rating could not be retrieved."})
    }
})

router.get('/getLiquorComments', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { _id } = req.query; // Use req.query to get the parameter from the query string
    const LiquorId = ObjectId.createFromHexString(_id);

    const result = await db.collection('Liquor').aggregate([
        { $match: { _id: LiquorId } },
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
        const comments = result[0].comments;
        res.status(200).json({ comments });
    } else {
        res.status(400).json({ message: "Comments could not be retrieved." });
    }
});

module.exports = router