//@todo Controllo ogni volta che importo nuovi dati se c'è un subscriber da notificare
//@todo Come notifico i subscriber che ci sono dati nuovi? (potrei aggiungere un campo quando chiedo tutte le mie richieste)

const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const auth = require('./auth');
const utils = require('./utils');

const isLogged = auth.isLogged;
const getUserIDByToken = auth.getUserIDByToken;
const logError = utils.logError;
const isPrivateUser = utils.isPrivateUser;
const validateRequest = Validator();
const router = new Router();


router.post('/upload', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);
    let i;
    let j;
    let text;
    let values;

    try {

        //if he's not logged in or he's not a PrivateUser he can't access this endpoint
        if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //check that every data he's trying to import is enabled for that user, and that data points are not already imported
        if (!(await checkEnabled(userID, req)) || !(await checkUniqueness(userID, req))) {
            res.status(403).send({error: "Imported invalid data"});
            return;
        }

        //import each observation into the database
        for(i=0; i<req.body.types.length; i++) {
            for(j=0; j<req.body.values[i].length; j++) {
                text = "INSERT INTO userdata VALUES($1, $2, $3, $4)";
                values = [userID, req.body.types[i], req.body.timestamps[i][j], req.body.values[i][j]];
                await db.query(text, values);
            }
        }

        res.status(200).send({message: "Data Imported"});
    } catch(error) {
        return logError(error, res)
    }
});


router.post('/stats', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a PrivateUser he can't access this endpoint
        if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //check that every data he's trying to get statistics for is enabled
        if (!(await checkEnabled(userID, req))) {
            res.status(403).send({error: "Getting statistics for invalid data"});
            return;
        }

        //get datapoints from the database
        let response = {};
        let i;
        let text;
        let values;
        let rows;
        for(i=0; i<req.body.types.length; i++) {

            text = "SELECT avg(value) as avg, date_part('month', timest) as month, date_part('year', timest) as year " +
                "FROM userdata WHERE userid=$1 and datatype=$2 " +
                "GROUP BY date_part('year', timest), date_part('month', timest);";
            values = [userID, req.body.types[i]];
            rows = await db.query(text, values);

            //convert each value for the mean from string to float
            let j;
            for(j=0; j<rows.rows.length; j++) {
                rows.rows[j].avg = parseFloat(rows.rows[j].avg)
            }

            //append observation to the response
            response[req.body.types[i]] = rows.rows
        }

        res.status(200).send({
            messsage: "Data retrieved",
            data : response
        })
    } catch(error) {
        return logError(error, res)
    }
});


//checks that every data a user is trying to import is enabled for that user
async function checkEnabled(id, req) {
    let i;
    let text;
    let values;
    let rows;

    for(i=0; i<req.body.types.length; i++) {
        text = "SELECT enabled FROM usersettings WHERE userid=$1 AND datatype=$2";
        values = [id, req.body.types[i]];
        rows = await db.query(text, values);

        //if enable is false or the datatype is not present at all in the database for that user
        if (!((rows.rowCount>0) && (rows.rows[0].enabled===true))) return false;
    }

    //if all dataType is enabled for that user, return true
    return true;
}


//checks that every data a user is trying to import is not already in the database
async function checkUniqueness(id, req) {
    let i;
    let j;
    let text;
    let values;
    let rows;

    for(i=0; i<req.body.types.length; i++) {
        for(j=0; j<req.body.values[i].length; j++) {
            text = "SELECT * FROM userdata WHERE userid=$1 AND datatype=$2 AND timest=$3";
            values = [id, req.body.types[i], req.body.timestamps[i][j]];
            rows = await db.query(text, values);

            //if the data point is already in the database
            if (rows.rowCount>0) return false;
        }
    }

    //if all data is not already in the database, return true
    return true;
}



module.exports = router;