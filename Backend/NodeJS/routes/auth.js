const Router = require('express-promise-router');
const db = require('../settings/dbconnection');
const sendEmail = require('../settings/mailer');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('config');

const hashPassword = require("../utils/security").hashPassword;
const router = new Router();


//lets a PrivateUser register to the service
router.post('/reg/single', async (req, res) => {
    //query the database to find if the email or fiscal code are already associated to an account
    let text = 'SELECT email FROM PrivateUser WHERE email = $1 OR fc = $2' +
        'UNION SELECT email FROM ThirdParty WHERE email = $1';
    let values = [req.body.email, req.body.fc];
    let rows = await db.query(text, values);

    if (rows.rowCount>0)
        return res.status(403).send({error: 'Already registered'});

    await(db.query('BEGIN'));

    //generate userID, activToken and insert into the database the new registration
    const ids = await insertIntoRegistration();
    //hash the password
    const password = await hashPassword(req.body.password);

    //insert into the database the new private user
    text = 'INSERT INTO PrivateUser VALUES($1, $2, $3, $4, $5, $6, $7)';
    values = [ids.userID, req.body.email, password, req.body.fc, req.body.full_name, req.body.birthdate, req.body.sex];
    await db.query(text, values);

    //send an email to activate the new account
    sendEmail(req, ids.activToken);

    await(db.query('COMMIT'));
    res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
});


//lets a ThirdParty register to the service
router.post('/reg/tp', async (req, res) => {
    //query the database to find if the email or piva are already associated to an account
    let text = 'SELECT email FROM ThirdParty WHERE email = $1 OR piva = $2' +
        'UNION SELECT email FROM PrivateUser WHERE email = $1';
    let values = [req.body.email, req.body.piva];
    let rows = await db.query(text, values);

    if (rows.rowCount>0)
        return res.status(403).send({error: 'Already registered'});

    await(db.query('BEGIN'));

    //generate userID and activToken and insert into the database the new registration
    const ids  = await insertIntoRegistration();
    //hash the password
    const password = await hashPassword(req.body.password);

    //insert into the database the new third party
    text = 'INSERT INTO ThirdParty VALUES($1, $2, $3, $4, $5, $6)';
    values = [ids.userID, req.body.email, password, req.body.piva, req.body.company_name, req.body.company_description];
    await db.query(text, values);

    //send an email to activate the new account
    sendEmail(req, ids.activToken);

    await(db.query('COMMIT'));
    res.status(200).send({message: "Registration successful, check your email to complete the creation of your account"})
});


//lets a user login
router.post('/login', async (req, res) => {
    let password;
    let userID;
    let type;

    //query the database to find an existing account with the provided credentials
    let values = [req.body.email];

    let text = 'SELECT userid, password FROM PrivateUser WHERE email = $1';
    let rows_private = await db.query(text, values);

    text = 'SELECT userid, password FROM ThirdParty WHERE email = $1';
    let rows_tp = await db.query(text, values);

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
    }, config.get('jwtPrivateKey'));

    res.status(200).send({
        authToken: token,
        userType: type
    })
});


//lets a user activate its account
router.get('/activ', async (req, res) => {

    //query the database to see if the account is already activated
    const rows = await db.query('SELECT activated FROM Registration WHERE activ_token = $1', [req.query.activToken]);

    //if there is no registration associated to the token in the database
    if(rows.rowCount===0)
        return res.status(401).send({error: 'Invalid token'});

    //if the account is already activated
    else if (rows.rows[0].activated === true)
        return res.status(403).send({error: 'Account already activated'});


    //set activated to true in the database
    const text = 'UPDATE Registration SET activated=$1 WHERE activ_token = $2';
    const values = [true, req.query.activToken];
    await db.query(text, values);

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


//generate activToken randomly
function getActivToken(userID) {
    let text = userID.toString();
    const possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    //generate a 10 characters string
    for (let i = 0; i < 10; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}



module.exports = router;



