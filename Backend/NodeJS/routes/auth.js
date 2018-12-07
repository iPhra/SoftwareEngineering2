const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const _ = require('lodash');

const validateRequest = Validator();
const router = new Router();
let userID= 0;
let token = 0;
let text;
let values;
let rows;
let loggedUsers = [];

router.post('/reg/single', validateRequest, async (req, res) => {
    try {
        text = 'SELECT email FROM PrivateUser WHERE email = $1 OR fc = $2' +
            'UNION SELECT email FROM ThirdParty WHERE email = $1';
        values = [req.body.email, req.body.fc];
        rows = await db.query(text, values);
        if(rows.rowCount!==0) {
            res.status(401).send('Already registered');
            return;
        }

        await insertIntoRegistration();

        text = 'INSERT INTO PrivateUser VALUES($1, $2, $3, $4, $5, $6, $7)';
        values = [userID, req.body.email, req.body.password, req.body.fc, req.body.full_name, req.body.birthdate, req.body.sex];
        await db.query(text, values);

        res.status(200).send("Registration successful, check your email to complete the creation of your account")
        //@todo send email
    }
    catch(error) {
        userID--;
        token--;
        console.log(error);
        res.status(400).send('Query error');
    }
});

router.post('/reg/tp', validateRequest, async (req, res) => {
    try {
        text = 'SELECT email FROM ThirdParty WHERE email = $1 OR piva = $2' +
            'UNION SELECT email FROM PrivateUser WHERE email = $1';
        values = [req.body.email, req.body.piva];
        rows = await db.query(text, values);
        if(rows.rowCount!==0) {
            res.status(401).send('Already registered');
            return;
        }

        await insertIntoRegistration();

        text = 'INSERT INTO ThirdParty VALUES($1, $2, $3, $4, $5, $6)';
        values = [userID, req.body.email, req.body.password, req.body.piva, req.body.company_name, req.body.company_description];
        await db.query(text, values);

        res.status(200).send("Registration successful, check your email to complete the creation of your account")
        //@todo send email
    }
    catch(error) {
        userID--;
        token--;
        console.log(error);
        res.status(400).send('Query error');
    }
});

//wrong credentials
//already logged in
router.post('/login', validateRequest, async (req, res) => {
    try {
        text = 'SELECT * FROM PrivateUser WHERE email = $1 AND password = $2' +
            'UNION SELECT * FROM ThirdParty WHERE email = $1 AND password = $2';
        values = [req.body.email, req.body.password];
        rows = await db.query(text, values);
        if(rows.rowCount===0) {
            res.status(401).send('Wrong Credentials');
            return;
        }

        await insertIntoRegistration();

        text = 'INSERT INTO PrivateUser VALUES($1, $2, $3, $4, $5, $6, $7)';
        values = [userID, req.body.email, req.body.password, req.body.fc, req.body.full_name, req.body.birthdate, req.body.sex];
        await db.query(text, values);

        res.status(200).send("Registration successful, check your email to complete the creation of your account")
        //@todo send email
    }
    catch(error) {
        userID--;
        token--;
        console.log(error);
        res.status(400).send('Query error');
    }
});

router.get('/activ', async (req, res) => {
    //@todo add a query to check if the account is already activated, if so return a 403 error "Already activated"
    try {
        text = 'UPDATE Registration SET activated=$1 WHERE token=$2 RETURNING *';
        values = [true, req.query.activToken];
        rows = await db.query(text, values);
        if(rows.rowCount===0) {
            res.status(401).send('Invalid token');
            return;
        }
        res.status(200).send("Account activated")
    }
    catch(error) {
        console.log(error);
        res.status(400).send('Query error');
    }
});

async function insertIntoRegistration() {
    userID++;
    token++;
    text = 'INSERT INTO Registration(userID, token, activated) VALUES($1, $2, $3)';
    values = [userID, token, false];
    await db.query(text, values)
}


module.exports = router;
