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
        res.status(403).send({error: "Wrong authentication"});
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

        res.status(200).send({message: "Settings updated"});
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/tp/info', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);

    //if he's not logged in or he's not a ThirdParty
    if (!isLogged(req.body.authToken) || !(await isThirdParty(userID))) {
        res.status(403).send({error: "Wrong authentication"});
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

        res.status(200).send({message: "Settings updated"});
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/single/data', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);

    //if he's not logged in or he's not a PrivateUser
    if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
        res.status(403).send({error: "Wrong authentication"});
        return
    }
    try {
        for(i=0; i<req.body.types.length; i++) {
            text = "SELECT * FROM usersettings WHERE userid=$1 and datatype=$2";
            values = [userID, req.body.types[i]];
            rows = await db.query(text, values);
            if(rows.rowCount===1) {
                text = "UPDATE usersettings SET enabled=$1 WHERE userid=$2 AND datatype=$3";
                values = [req.body.enabled[i], userID, req.body.types[i]];
                await db.query(text, values)
            }
            else {
                text = "INSERT INTO usersettings VALUES($1, $2, $3)";
                values = [userID, req.body.types[i], req.body.enabled[i]]
                await db.query(text, values)
            }
        }
        res.status(200).send({message: "Settings updated"});
    } catch(error) {
        return logError(error, res)
    }
});



module.exports = router;