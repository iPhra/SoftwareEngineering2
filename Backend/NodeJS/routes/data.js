const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const auth = require('./auth');
const isLogged = auth.isLogged;
const getUserID = auth.getUserID;
const utils = require('./utils');
const logError = utils.logError;
const isPrivateUser = utils.isPrivateUser;

const validateRequest = Validator();
const router = new Router();
let userID;

router.post('/upload', validateRequest, async (req, res) => {
    userID = getUserID(req.body.authToken);

    //if he's not logged in or he's not a PrivateUser
    if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
        res.status(403).send("Wrong authentication");
        return
    }

    try {
        for(i=0; i<req.body.types.length; i++) {
            text = "INSERT INTO userdata VALUES($1, $2, $3, $4)";
            values = [userID, req.body.timestamps[i], req.body.types[i], req.body.values[i]];
            await db.query(text, values);
        }
        res.status(200).send("Data Imported");
    } catch(error) {
        return logError(error, res)
    }
});



module.exports = router;