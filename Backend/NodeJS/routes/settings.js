const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const isLogged = require('./auth').isLogged;
const logError = require('./errorHandler').logError;

const validateRequest = Validator();
const router = new Router();

router.post('/single/info', validateRequest, async (req, res) => {
    if (!isLogged(req.body.authToken)) {
        res.status(403).send("You are not logged in");
        return
    }

    try {
        if(req.body.password) {
            text = "UPDATE PrivateUser SET password=$1 WHERE userID=$2";
            values = [req.body.password, req.body.authToken];
            await db.query(text, values);
        }

        if(req.body.full_name) {
            text = "UPDATE PrivateUser SET full_name=$1 WHERE userID=$2";
            values = [req.body.full_name, req.body.authToken];
            await db.query(text, values);
        }

        if(req.body.birthdate) {
            text = "UPDATE PrivateUser SET birthdate=$1 WHERE userID=$2";
            values = [req.body.birthdate, req.body.authToken];
            await db.query(text, values);
        }

        if(req.body.sex) {
            text = "UPDATE PrivateUser SET sex=$1 WHERE userID=$2";
            values = [req.body.sex, req.body.authToken];
            await db.query(text, values);
        }

        res.status(200).send("Settings Updated");
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/tp/info', validateRequest, async (req, res) => {
    if (!isLogged(req.body.authToken)) {
        res.status(403).send("You are not logged in");
        return
    }

    try {
        if(req.body.password) {
            text = "UPDATE ThirdParty SET password=$1 WHERE userID=$2";
            values = [req.body.password, req.body.authToken];
            await db.query(text, values);
        }

        if(req.body.company_name) {
            text = "UPDATE ThirdParty SET company_name=$1 WHERE userID=$2";
            values = [req.body.company_name, req.body.authToken];
            await db.query(text, values);
        }

        if(req.body.company_description) {
            text = "UPDATE ThirdParty SET company_description=$1 WHERE userID=$2";
            values = [req.body.company_description, req.body.authToken];
            await db.query(text, values);
        }

        res.status(200).send("Settings Updated");
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/single/data', validateRequest, async (req, res) => {
    if (!isLogged(req.body.authToken)) {
        res.status(403).send("You are not logged in");
        return
    }

    try {
        console.log(req.body);
        res.status(200).send("Settings Updated");
    } catch(error) {
        return logError(error, res)
    }
});



module.exports = router;