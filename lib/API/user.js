const express = require('express');
const {getClient} = require('../database');
const {generateToken} = require('../jwtUtils')
const {randString, sendMail} = require('../emailUtils')
const router = express.Router();

//API Section
// User Registration
router.post('/register', async (req, res, next) => {
    const db = getClient().db('AlcoholDatabase')
    const {FirstName, LastName, Username, Password, Email, Phone} = req.body //May need to be adjusted if we need to have email verification

    //Verification to check if username and email exists in the database
    let results = await db.collection('Users').find({ Username:Username}).toArray()
    if(results.length > 0){
        return res.status(409).json({ error: 'Username already exists' });
    }
    results = await db.collection('Users').find({ Email:Email}).toArray()
    if(results.length > 0){
        return res.status(409).json({ error: 'Email already exists' });
    }

    //Used to auto-increment UserId using last register user's id
    let nextUserId
    const lastUser = await db.collection('Users').find().sort({ UserId:-1 }).limit(1).toArray()
    if(lastUser.length > 0){
        nextUserId = lastUser[0].UserId + 1
    }
    else{
        nextUserId = 1
    }

    const uniqueString = randString() //Used to help create a unique verification link that is attached to the user's account

    const user = {UserId:nextUserId, FirstName, LastName, Username, Password, Email, Phone, Verified:false, uniqueString, Drinks:[]}

    await db.collection('Users').insertOne(user)
    sendMail(Email, uniqueString, 1)

    var ret = {user, Message:"User successfully registered. Verification email has been sent."}
    res.status(201).json(ret)
});

// User Login
router.post('/login', async (req, res, next) => {
    const db = getClient().db('AlcoholDatabase')
    const { Username, Password } = req.body
    const results = await db.collection('Users').find({ Username:Username,Password:Password}).toArray()
    let user

    if( results.length > 0 && results[0].Verified) {
        user = results[0]
    }
    else if(results.length > 0 && !results[0].Verified){
        return res.status(401).json({error:"Account has not been verified"}) 
    }
    else{
        return res.status(404).json({error:"Invalid Username or Password"})
    }

    const token = generateToken(user.UserId)
    var ret = {user, token, Message:"User successfully logged in"}
    res.cookie('token', token, {
        httpOnly: true,
        secure: true,
        sameSite: "none"
    }).status(200).json(ret)
})

// User Verification - Verifies user in the database when they click email link.
router.get('/verify/:uniqueString', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const{uniqueString} = req.params
    const result = await db.collection('Users').updateOne({ uniqueString: uniqueString }, { $set: { Verified: true } })// Finds user using uniqueString then updates Verified to true
    console.log(result)
    if(result.matchedCount > 0){
        res.status(200).json({Message:"User has been successfully verified"})
    }
    else{
        return res.status(404).json({error:"Error validating user"})
    }
})

//Forget Password - User enters email address and email is sent with a link to change password
router.post('/recoverAccount', async(req, res) => {
    const db = getClient().db('AlcoholDatabase')
    const {Email} = req.body
    const uniqueString = randString()
    const result = await db.collection('Users').updateOne({ Email: Email }, { $set: { uniqueString: uniqueString } })
    if(result.matchedCount > 0){
        sendMail(Email, uniqueString, 2)
        res.status(200).json({Message:"Recovery email has been sent"})
    }
    else{
        return res.status(404).json({error:"Email not found"})
    }
})

//Gets the change password page from email link
router.get('/changePassword/:uniqueString', async(req,res) => {
    const{uniqueString} = req.params
    if(uniqueString){    
            res.status(200).json({Message:"Directing user to change password"})
        }
    else{
        return res.status(401).json({error:"Error with directing user"})
    }
})

//Change Password - Requires the user to successfully input a new password and the same password again to confirm it
router.post('/changePassword/:uniqueString', async(req,res) => {
    const db = getClient().db('AlcoholDatabase')
    
    const{uniqueString} = req.params
    const{newPassword, confirmPassword} = req.body
    console.log(newPassword, confirmPassword)
    if(newPassword === confirmPassword){    
        const result = await db.collection('Users').updateOne({ uniqueString: uniqueString }, { $set: { Password: newPassword } })
        if(result){
            res.status(200).json({Message:"User has successfully changed their password"})
        }
        else{
            return res.status(400).json({error:"Error changing password"})
        }
    }
    else{
        return res.status(401).json({error:"Passwords do not match"})
    }
})

module.exports = router;
