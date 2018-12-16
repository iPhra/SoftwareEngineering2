//@todo Mettere una funzione sicura per creare l'userID
//@todo Differenziare userID da activToken ed authToken
//@todo Aggiungere encryption ed EncryptionManager

const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const sendEmail = require('../settings/mailer');
const bcrypt = require('bcryptjs');

const logError = require("./utils").logError;
const validateRequest = Validator();
const router = new Router();

let loggedUsers = {}; //hashmap authToken : userID


router.post('/reg/single', validateRequest, async (req, res) => {
    let text;
    let values;
    let rows;
    let userID;

    //query the database to find if the email or fiscal code are already associated to an account
    try {
        text = 'SELECT email FROM PrivateUser WHERE email = $1 OR fc = $2' +
            'UNION SELECT email FROM ThirdParty WHERE email = $1';
        values = [req.body.email, req.body.fc];
        rows = await db.query(text, values);

        if (rows.rowCount>0) {
            res.status(403).send({error: 'Already registered'});
            return;
        }
    } catch(error) {
        return logError(error, res);
    }

    try {
        await(db.query('BEGIN'));

        //generate userID and insert into the database the new registration
        userID = await insertIntoRegistration();
        const password = await hashPassword(req.body.password);

        //insert into the database the new private user
        text = 'INSERT INTO PrivateUser VALUES($1, $2, $3, $4, $5, $6, $7)';
        values = [userID, req.body.email, password, req.body.fc, req.body.full_name, req.body.birthdate, req.body.sex];
        await db.query(text, values);

        //send an email to activate the new account
        sendEmail(req, userID); //@todo diversificare authToken da userID

        await(db.query('COMMIT'));
        res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
    } catch(error) {
        await db.query('ROLLBACK');
        return logError(error, res)
    }

});


router.post('/reg/tp', validateRequest, async (req, res) => {
    let text;
    let values;
    let rows;
    let userID;

    //query the database to find if the email or piva are already associated to an account
    try {
        text = 'SELECT email FROM ThirdParty WHERE email = $1 OR piva = $2' +
            'UNION SELECT email FROM PrivateUser WHERE email = $1';
        values = [req.body.email, req.body.piva];
        rows = await db.query(text, values);

        if (rows.rowCount>0) {
            res.status(403).send({error: 'Already registered'});
            return;
        }
    } catch(error) {
        return logError(error, res)
    }

    try {
        await(db.query('BEGIN'));

        //generate userID and insert into the database the new registration
        userID = await insertIntoRegistration();
        const password = await hashPassword(req.body.password);

        //insert into the database the new third party
        text = 'INSERT INTO ThirdParty VALUES($1, $2, $3, $4, $5, $6)';
        values = [userID, req.body.email, password, req.body.piva, req.body.company_name, req.body.company_description];
        await db.query(text, values);

        //send an email to activate the new account
        sendEmail(req, userID); //@todo diversificare authToken da userID

        await(db.query('COMMIT'));
        res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }

});


router.post('/login', validateRequest, async (req, res) => {
    let text;
    let rows_private;
    let rows_tp;
    let password;
    let userID;

    //query the database to find an existing account with the provided credentials
    try {
        let values = [req.body.email];

        text = 'SELECT userid, password FROM PrivateUser WHERE email = $1';
        rows_private = await db.query(text, values);

        text = 'SELECT userid, password FROM ThirdParty WHERE email = $1';
        rows_tp = await db.query(text, values);

        if(rows_private.rowCount>0) {
            password = rows_private.rows[0].password;
            userID = rows_private.rows[0].userid;
        }
        else if(rows_tp.rowCount>0) {
            password = rows_tp.rows[0].password;
            userID = rows_tp.rows[0].userid;
        }
        else return res.status(401).send({error: "Email does not exist"});

        //if the password is wrong
        if(!(await bcrypt.compare(req.body.password, password))) return res.status(401).send({error: 'Wrong password'});
    }
    catch(error) {
        return logError(error, res)
    }

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
        "userType" :  rows_tp.rowCount>0 ? "ThirdParty" : "PrivateUser"
    })
});


router.post('/logout', validateRequest, async (req, res) => {

    //if the user is not logged in
    if (!(req.body.authToken in loggedUsers)) {
        res.status(401).send({error: 'Not logged in'});
        return;
    }

    delete loggedUsers[req.body.authToken];
    res.status(200).send({message: "Logged out"});
});


router.get('/activ', async (req, res) => {

    //query the database to see if the account is already activated
    try {
        const rows = await db.query('SELECT activated FROM Registration WHERE userID = $1', [req.query.activToken]);

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
        const text = 'UPDATE Registration SET activated=$1 WHERE userid=$2 RETURNING *';
        const values = [true, req.query.activToken];
        await db.query(text, values);
    } catch(error) {
        //no need to rollback, as the database can't have been updated if the query failed, since it's the only one
        return logError(error, res)
    }

    res.status(200).send({message: "Account activated"})
});

//creates the userID and inserts it into the Registration table
async function insertIntoRegistration() {

    //evaluates the total number of registered users from the database, and generates the userID based on that value
    const rows = await db.query('SELECT count(*) as userID FROM Registration');
    const id = (+rows.rows[0].userid +1).toString(); //@todo generarlo in modo intelligente dato questo valore

    //insert the userID into the Registration table
    const text = 'INSERT INTO Registration(userID, activated) VALUES($1, $2)';
    const values = [id, false];
    await db.query(text, values);
    return id;
}


//true if the authToken of the user is present in the hasmap, ie he's logged in the server
function isLogged(authToken) {
    return authToken in loggedUsers
}


//given the authToken of a user, returns its userID from the hashmap of logged users
function getUserIDByToken(authToken) {
    return loggedUsers[authToken]
}


async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}



module.exports = router;
module.exports.isLogged = isLogged;
module.exports.getUserIDByToken = getUserIDByToken;



