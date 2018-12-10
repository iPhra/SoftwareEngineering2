const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const auth = require('./auth');
const isLogged = auth.isLogged;
const getUserID = auth.getUserID;
const utils = require('./utils');
const logError = utils.logError;
const isThirdParty = utils.isThirdParty;
const isPrivateUser = utils.isPrivateUser;

const validateRequest = Validator();
const router = new Router();
let userID;

router.post('/single/info', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);
    //if he's not logged in or he's not a PrivateUser
    if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
        res.status(403).send("Wrong authentication");
        return
    }

    try {
        if(req.body.password) {
            text = "UPDATE PrivateUser SET password=$1 WHERE userID=$2";
            values = [req.body.password, userID];
            await db.query(text, values);
        }

        if(req.body.full_name) {
            text = "UPDATE PrivateUser SET full_name=$1 WHERE userID=$2";
            values = [req.body.full_name, userID];
            await db.query(text, values);
        }

        if(req.body.birthdate) {
            text = "UPDATE PrivateUser SET birthdate=$1 WHERE userID=$2";
            values = [req.body.birthdate, userID];
            await db.query(text, values);
        }

        if(req.body.sex) {
            text = "UPDATE PrivateUser SET sex=$1 WHERE userID=$2";
            values = [req.body.sex, userID];
            await db.query(text, values);
        }

        res.status(200).send("Settings Updated");
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/tp/info', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);
    //if he's not logged in or he's not a ThirdParty
    if (!isLogged(req.body.authToken) || !(await isThirdParty(userID))) {
        res.status(403).send("Wrong authentication");
        return
    }

    try {

        if(req.body.password) {
            text = "UPDATE ThirdParty SET password=$1 WHERE userID=$2";
            values = [req.body.password, userID];
            await db.query(text, values);
        }

        if(req.body.company_name) {
            text = "UPDATE ThirdParty SET company_name=$1 WHERE userID=$2";
            values = [req.body.company_name, userID];
            await db.query(text, values);
        }

        if(req.body.company_description) {
            text = "UPDATE ThirdParty SET company_description=$1 WHERE userID=$2";
            values = [req.body.company_description, userID];
            await db.query(text, values);
        }

        res.status(200).send("Settings Updated");
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/single/data', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);
    //if he's not logged in or he's not a PrivateUser
    if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
        res.status(403).send("Wrong authentication");
        return
    }
    try {
        for(i=0; i<req.body.types.length; i++) {
            console.log(req.body.types[i])
        }
        res.status(200).send("Settings Updated");
    } catch(error) {
        return logError(error, res)
    }
});



module.exports = router;