
//@todo Aggiungere encryption ed EncryptionManager
//@todo Salvare jwt key nelle enviromental variables
//@todo rivedere dove stanno i catch per i login

const Router = require('express-promise-router');
const db = require('../settings/dbconnection');
const sendEmail = require('../settings/mailer');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const hashPassword = require("./utils").hashPassword;
const logError = require("./utils").logError;
const getActivToken = require("./utils").getAuthToken;
const router = new Router();


router.post('/reg/single', async (req, res) => {
    let text;
    let values;
    let rows;

    //query the database to find if the email or fiscal code are already associated to an account
    try {
        text = 'SELECT email FROM PrivateUser WHERE email = $1 OR fc = $2' +
            'UNION SELECT email FROM ThirdParty WHERE email = $1';
        values = [req.body.email, req.body.fc];
        rows = await db.query(text, values);

        if (rows.rowCount>0)
            return res.status(403).send({error: 'Already registered'});

    } catch(error) {
        return logError(error, res);
    }

    try {
        await(db.query('BEGIN'));

        //generate userID and insert into the database the new registration
        const ids = await insertIntoRegistration();
        const password = await hashPassword(req.body.password);

        //insert into the database the new private user
        text = 'INSERT INTO PrivateUser VALUES($1, $2, $3, $4, $5, $6, $7)';
        values = [ids.userID, req.body.email, password, req.body.fc, req.body.full_name, req.body.birthdate, req.body.sex];
        await db.query(text, values);

        //send an email to activate the new account
        sendEmail(req, ids.activToken);

        await(db.query('COMMIT'));
        res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
    } catch(error) {
        await db.query('ROLLBACK');
        return logError(error, res)
    }

});


router.post('/reg/tp', async (req, res) => {
    let text;
    let values;
    let rows;

    //query the database to find if the email or piva are already associated to an account
    try {
        text = 'SELECT email FROM ThirdParty WHERE email = $1 OR piva = $2' +
            'UNION SELECT email FROM PrivateUser WHERE email = $1';
        values = [req.body.email, req.body.piva];
        rows = await db.query(text, values);

        if (rows.rowCount>0)
            return res.status(403).send({error: 'Already registered'});
    } catch(error) {
        return logError(error, res)
    }

    try {
        await(db.query('BEGIN'));

        //generate userID and insert into the database the new registration
        const ids  = await insertIntoRegistration();
        const password = await hashPassword(req.body.password);

        //insert into the database the new third party
        text = 'INSERT INTO ThirdParty VALUES($1, $2, $3, $4, $5, $6)';
        values = [ids.userID, req.body.email, password, req.body.piva, req.body.company_name, req.body.company_description];
        await db.query(text, values);

        //send an email to activate the new account
        sendEmail(req, ids.activToken);

        await(db.query('COMMIT'));
        res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }

});


router.post('/login', async (req, res) => {
    let text;
    let rows_private;
    let rows_tp;
    let password;
    let userID;
    let type;

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
            type = "PrivateUser"
        }
        else if(rows_tp.rowCount>0) {
            password = rows_tp.rows[0].password;
            userID = rows_tp.rows[0].userid;
            type = "ThirdParty"
        }
        else return res.status(401).send({error: "Email provided does not exist"});

        //if the password is wrong
        if(!(await bcrypt.compare(req.body.password, password))) return res.status(401).send({error: 'Wrong password'});

        //generate jwt token containing userid and the type of the account
        const token = jwt.sign({
            userid: userID,
            usertype: type
        }, 'gruosso');

        res.status(200).send({
            "message" : "Login successful",
            "authToken" : token,
            "userType" :  type
        })
    } catch(error) {
        return logError(error, res)
    }
});


router.get('/activ', async (req, res) => {

    //query the database to see if the account is already activated
    try {
        const rows = await db.query('SELECT activated FROM Registration WHERE activ_token = $1', [req.query.activToken]);

        //if there is no registration associated to the token in the database
        if(rows.rowCount===0)
            return res.status(401).send({error: 'Invalid token'});

        //if the account is already activated
        else if (rows.rows[0].activated === true)
            return res.status(403).send({error: 'Account already activated'});

    }
    catch(error) {
        return logError(error, res)
    }

    //set activated to true in the database
    try {
        const text = 'UPDATE Registration SET activated=$1 WHERE activ_token = $2';
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
    const rows = await db.query('SELECT count(*) as n FROM Registration');
    const id = (+rows.rows[0].n +1).toString();

    //insert the authToken into the Registration table
    const activToken = getActivToken(id);
    const text = 'INSERT INTO registration VALUES($1, $2)';
    const values = [activToken, false];
    await db.query(text, values);

    return {
        userID: id,
        activToken: activToken
    };
}



module.exports = router;



