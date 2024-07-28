const express = require('express');
const {getClient} = require('../database');
const {generateToken} = require('../jwtUtils')
const {randString, sendMail} = require('../emailUtils')
const router = express.Router();

//API Section
// User Registration
router.post('/register', async (req, res, next) => {
    const db = getClient().db('AlcoholDatabase')
    const {FirstName, LastName, Username, Password, Email, Phone} = req.body

    const usernameRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9-_]{3,18}$/;
    const passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,32}$/;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const phoneRegex = /^\d{3}-\d{3}-\d{4}$/;

    if (!usernameRegex.test(Username)) {
        return res.status(400).json({ error: 'Username does not meet the criteria.' });
    }
    if (!passwordRegex.test(Password)) {
        return res.status(400).json({ error: 'Password does not meet the criteria.' });
    }
    if (!emailRegex.test(Email)) {
        return res.status(400).json({ error: 'Email is not valid.' });
    }
    if (!phoneRegex.test(Phone)) {
        return res.status(400).json({ error: 'Phone number is not valid.' });
    }

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

    const passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,32}$/;
    
    if (!passwordRegex.test(newPassword)) {
        return res.status(400).json({ error: 'New Password does not meet the criteria.' });
    }

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

// Retrieve User Username
router.post('/getUsername', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { userId } = req.body;

    const result = await db.collection('Users').findOne({ _id: userId });

    if (result) {
        res.status(200).json({ Username: result.Username });
    } else {
        res.status(404).json({ error: 'User not found' });
    }
});

// Retrieve User Password
router.post('/getPassword', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { Username } = req.body;

    const result = await db.collection('Users').findOne({ Username: Username });

    if (result) {
        res.status(200).json({ Password: result.Password });
    } else {
        res.status(404).json({ error: 'User not found' });
    }
});

// Change Username
router.post('/changeUsername', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { userId, newUsername } = req.body;

    const result = await db.collection('Users').findOneAndUpdate(
        { UserId: userId },
        { $set: { Username: newUsername } },
        { new: true }
    );

    if (result) {
        res.status(200).json({ message: 'Username updated successfully' });
    } else {
        res.status(404).json({ error: 'User not found' });
    }
});

// Delete Account
router.post('/deleteAccount', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { userId } = req.body;

    const result = await db.collection('Users').findOneAndDelete({ UserId: userId });

    if (result) {
        res.status(200).json({ message: 'Account deleted successfully' });
    } else {
        res.status(404).json({ error: 'User not found' });
    }
});

// New Change Password API call to change directly though the app
router.post('/changePassword', async (req, res) => {
    const db = getClient().db('AlcoholDatabase');
    const { userId, newPassword, confirmPassword } = req.body;

    const passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,32}$/;

    if (!passwordRegex.test(newPassword)) {
        return res.status(400).json({ error: 'New Password does not meet the criteria.' });
    }

    if (newPassword === confirmPassword) {
        const result = await db.collection('Users').updateOne(
            { UserId: userId },
            { $set: { Password: newPassword } }
        );
        if (result.modifiedCount > 0) {
            res.status(200).json({ Message: 'User has successfully changed their password' });
        } else {
            res.status(400).json({ error: 'Error changing password' });
        }
    } else {
        res.status(401).json({ error: 'Passwords do not match' });
    }
});

module.exports = router;