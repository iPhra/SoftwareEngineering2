const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const auth = require('./auth');
const utils = require('./utils');

const isLogged = auth.isLogged;
const getUserID = auth.getUserID;
const logError = utils.logError;
const isPrivateUser = utils.isPrivateUser;
const validateRequest = Validator();
const router = new Router();

let userID;
let text;
let values;
let res;
let i;

router.post('/upload', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);

    try {

        //if he's not logged in or he's not a PrivateUser he can't access this endpoint
        if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //check that every data he's trying to import is enabled for that user
        if (!(await checkValidity(userID, req))) {
            res.status(403).send({error: "Imported invalid data"});
            return;
        }

        //import each observation into the database
        for(i=0; i<req.body.types.length; i++) {
            text = "INSERT INTO userdata VALUES($1, $2, $3, $4)";
            values = [userID, req.body.timestamps[i], req.body.types[i], req.body.values[i]];
            await db.query(text, values);
        }

        res.status(200).send({message: "Data Imported"});
    } catch(error) {
        return logError(error, res)
    }
});

router.post('/stats', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);

    try {

        //if he's not logged in or he's not a PrivateUser he can't access this endpoint
        if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //check that every data he's trying to import is enabled for that user
        if (!(await checkValidity(userID, req))) {
            res.status(403).send({error: "Getting statistics for invalid data"});
            return;
        }

        //import each observation into the database
        for(i=0; i<req.body.types.length; i++) {
            text = "SELECT (value, timestp) FROM userdata WHERE userid=$1 and datatype=$2";
            values = [userID, req.body.types[i]];
            await db.query(text, values);
        }


    } catch(error) {
        return logError(error, res)
    }
});

//checks that every data a user is trying to import is enabled for that user
async function checkValidity(id, req) {

    for(i=0; i<req.body.types.length; i++) {
        text = "SELECT enabled FROM usersettings WHERE userid=$1 AND datatype=$2";
        values = [id, req.body.types[i]];
        res = await db.query(text, values);

        //if enable is false or the datatype is not present at all in the database for that user
        if (!((res.rowCount===1) && (res.rows[0].enabled===true))) return false;
    }

    //if all dataType is enabled for that user, return true
    return true;
}



module.exports = router;