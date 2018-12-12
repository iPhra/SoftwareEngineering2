//@todo Mettere una funzione sicura per creare l'userID
//@todo Differenziare userID da activToken ed authToken
//@todo Rivedere la gestione degli errori e rollback
//@todo Aggiungere encryption ed EncryptionManager

const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const sendEmail = require('../settings/mailer');
const _ = require('lodash');

const logError = require("./utils").logError;
const validateRequest = Validator();
const router = new Router();

let text;
let values;
let rows_tp;
let rows_private;
let rows;
let loggedUsers = {}; //hashmap authToken : userID
let userID;


router.post('/reg/single', validateRequest, async (req, res) => {

    //query the database to find if the email or fiscal code are already associated to an account
    try {
        text = 'SELECT email FROM PrivateUser WHERE email = $1 OR fc = $2' +
            'UNION SELECT email FROM ThirdParty WHERE email = $1';
        values = [req.body.email, req.body.fc];
        rows = await db.query(text, values);

        if (rows.rowCount !== 0) {
            res.status(401).send({error: 'Already registered'});
            return;
        }
    } catch(error) {
        return logError(error, res);
    }

    try {
        //generate userID and insert into the database the new registration
        userID = await insertIntoRegistration();

        //insert into the database the new private user
        text = 'INSERT INTO PrivateUser VALUES($1, $2, $3, $4, $5, $6, $7)';
        values = [userID, req.body.email, req.body.password, req.body.fc, req.body.full_name, req.body.birthdate, req.body.sex];
        await db.query(text, values);

        //send an email to activate the new account
        sendEmail(req, userID); //@todo diversificare authToken da userID

        res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
    } catch(error) {
        console.log(error);

        //rollback the db by deleting the rows i possibly inserted
        await db.query("DELETE FROM Registration WHERE userID=$1",userID);
        await db.query("DELETE FROM PrivateUser WHERE email=$1",req.body.email);

        res.status(400).send({error: 'Query error'});
    }

});

router.post('/reg/tp', validateRequest, async (req, res) => {

    //query the database to find if the email or piva are already associated to an account
    try {
        text = 'SELECT email FROM ThirdParty WHERE email = $1 OR piva = $2' +
            'UNION SELECT email FROM PrivateUser WHERE email = $1';
        values = [req.body.email, req.body.piva];
        rows = await db.query(text, values);

        if (rows.rowCount !== 0) {
            res.status(401).send({error: 'Already registered'});
            return;
        }
    } catch(error) {
        return logError(error, res)
    }

    try {
        //generate userID and insert into the database the new registration
        userID = await insertIntoRegistration();

        //insert into the database the new third party
        text = 'INSERT INTO ThirdParty VALUES($1, $2, $3, $4, $5, $6)';
        values = [userID, req.body.email, req.body.password, req.body.piva, req.body.company_name, req.body.company_description];
        await db.query(text, values);

        //send an email to activate the new account
        sendEmail(req, userID); //@todo diversificare authToken da userID

        res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
    } catch(error) {
        console.log(error);

        //rollback the db by deleting the rows i possibly inserted
        await db.query("DELETE FROM Registration WHERE userID=$1",userID);
        await db.query("DELETE FROM ThirdParty WHERE email=$1",req.body.email);

        res.status(400).send({error: 'Query error'});
    }

});

router.post('/login', validateRequest, async (req, res) => {

    //query the database to find an existing account with the provided credentials
    try {
        text = 'SELECT userid FROM PrivateUser WHERE email = $1 AND password = $2';
        values = [req.body.email, req.body.password];
        rows_private = await db.query(text, values);

        text = 'SELECT userid FROM ThirdParty WHERE email = $1 AND password = $2';
        rows_tp = await db.query(text, values);
    }
    catch(error) {
        return logError(error, res)
    }

    //if no account with that credentials is found
    if(rows_private.rowCount===0 && rows_tp.rowCount===0) {
        res.status(401).send({error: 'Wrong credentials'});
        return;
    }

    //get the userID from the right table, based on whether he's a third party or private user
    userID = rows_tp.rowCount!==0? rows_tp.rows[0].userid : rows_private.rows[0].userid;

    //if the user is already logged in, i.e. his userid is a value (not key!) in the hashmap of logged users
    if(Object.values(loggedUsers).indexOf(userID) > -1) {
        res.status(403).send({error: 'Already logged in'});
        return;
    }

    //add the user to the logged users list and send the authToken back to the client
    loggedUsers[userID] = userID; //@todo cambiare! la chiave della hashmap deve essere authToken!
    res.status(200).send({
        "message" : "Login successful",
        "authToken" : userID, //@todo cambiare! questo deve essere authToken
        "userType" :  rows_tp.rowCount!==0 ? "ThirdParty" : "PrivateUser"
    })
});

router.get('/logout', async (req, res) => {

    //if the user is not logged in
    if (!(req.query.authToken in loggedUsers)) {
        res.status(403).send({error: 'Not logged in'});
        return;
    }

    delete loggedUsers[req.query.authToken];
    res.status(200).send({message: "Logged out"});
});

router.get('/activ', async (req, res) => {

    //query the database to see if the account is already activated
    try {
        rows = await db.query('SELECT activated FROM Registration WHERE userID = $1', [req.query.activToken]);

        //if there is no registration associated to the token in the database
        if(rows.rowCount===0) {
            res.status(401).send({error: 'Invalid token'});
            return;
        }

        //if the account is already activated
        else if (rows.rows[0].activated === true) {
            res.status(403).send({error: 'Account already activated'});
            return;
        }
    }
    catch(error) {
        return logError(error, res)
    }

    //set activated to true in the database
    try {
        text = 'UPDATE Registration SET activated=$1 WHERE userid=$2 RETURNING *';
        values = [true, req.query.activToken];
        await db.query(text, values);
    } catch(error) {
        return logError(error, res)
    }

    res.status(200).send({message: "Account activated"})
});

//creates the userID and inserts it into the Registration table
async function insertIntoRegistration() {

    //evaluates the total number of registered users from the database, and generates the userID based on that value
    rows = await db.query( text = 'SELECT count(*) as userID FROM Registration');
    const id = (+rows.rows[0].userid +1).toString(); //@todo generarlo in modo intelligente dato questo valore

    //insert the userID into the Registration table
    text = 'INSERT INTO Registration(userID, activated) VALUES($1, $2)';
    values = [id, false];
    await db.query(text, values);
    return id;
}

//true if the authToken of the user is present in the hasmap, ie he's logged in the server
function isLogged(authToken) {
    return authToken in loggedUsers
}

//given the authToken of a user, returns its userID from the hashmap of logged users
function getUserID(authToken) {
    return loggedUsers[authToken]
}


module.exports = router;
module.exports.isLogged = isLogged;
module.exports.getUserID = getUserID;



