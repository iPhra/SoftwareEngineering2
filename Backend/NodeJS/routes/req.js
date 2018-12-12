//@todo Rivedere codici d'errore (anche sul resto del progetto!)
//@todo Gestire i rollback!
//@todo Devo notificare la Third Party del risultato di una richiesta?
//@todo Ogni volta che apro il server devo controllare se i countdown delle richieste sono scaduti

const Router = require('express-promise-router');
const Validator = require('../schemas/validator');
const db = require('../settings/dbconnection');
const auth = require('./auth');
const utils = require('./utils');

const isLogged = auth.isLogged;
const getUserIDByToken = auth.getUserIDByToken;
const logError = utils.logError;
const isThirdParty = utils.isThirdParty;
const isPrivateUser = utils.isPrivateUser;
const validateRequest = Validator();
const router = new Router();


router.post('/tp/sendSingle', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a ThirdParty
        if (!isLogged(req.body.authToken) || !(await isThirdParty(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //if the receiving user does not exist
        if ((await getUserIDByEmail(req)).rowCount===0) {
            res.status(403).send({error: "User does not exist"});
            return
        }

        //if there's a pending request already from the TP to the PU
        if(await checkPendingRequests(userID, req)) {
            res.status(403).send({error: "There already is a pending request"});
            return
        }

        //insert request into SingleRequest table
        let i;
        const reqID = await getReqID();
        const today = new Date().toISOString().slice(0, 10);
        const receiver_id = (await getUserIDByEmail(req)).rows[0].userid;
        let text = 'INSERT INTO singlerequest VALUES($1, $2, $3, $4, $5, $6, $7)';
        let values = [reqID, userID, receiver_id, req.body.subscribing, "pending", req.body.subscribing? req.body.duration : null, today];
        await db.query(text, values);

        //for each type, insert the type into RequestContent table
        for(i=0; i<req.body.types.length; i++) {
            text = "INSERT INTO requestcontent VALUES($1, $2)";
            values = [reqID, req.body.types[i]];
            await db.query(text, values);
        }

        res.status(200).send({message: "Request sent"});
    } catch(error) {
        return logError(error, res)
    }
});


router.post('/tp/downloadSingle', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a ThirdParty
        if (!isLogged(req.body.authToken) || !(await isThirdParty(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //retrieve status of the request
        let text = "SELECT * FROM singlerequest WHERE req_id = $1";
        let values = [req.body.reqID];
        let rows = await db.query(text, values);

        //if the request is not present or if it was not approved
        if(rows.rowCount===0 || rows.rows[0].status!== 'accepted') {
            res.status(403).send({error: "Can't download data"});
            return
        }

        //for each type, retrieve values from the user
        let dataTypes = await getRequestContent(req);
        let i;

        for(i=0; i<dataTypes.length; i++) {
            text = "SELECT value FROM userdata WHERE userid = $1 AND datatype = $2 and timest::date <= $3";
            values = [rows.rows[0].receiver_id, dataTypes[i].datatype, rows.rows[0].req_date];
            rows = await db.query(text, values);

            //@todo add values to response
        }


        res.status(200).send({message: "Request sent"});
    } catch(error) {
        return logError(error, res)
    }
});


router.post('/single/choice', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a ThirdParty
        if (!isLogged(req.body.authToken) || !(await isPrivateUser(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //if the request doesn't exist or if it's not pending
        if (!(await checkReqExistance(req))) {
            res.status(403).send({error: "User does not exist"});
            return
        }

        //update the request, if choice is true then the request is accepted
        let text = 'UPDATE singlerequest SET status=$1 WHERE req_id = $2';
        let values = [req.body.choice? 'accepted' : 'refused', req.body.reqID];
        await db.query(text, values);

        //@todo notificare la third party?

        res.status(200).send({message: "Action successful"});
    } catch(error) {
        return logError(error, res)
    }
});


//checks if a given PrivateUser exists in the db, given his email and fc, and returns the result of the query
async function getUserIDByEmail(req) {
    const text = "SELECT userid FROM privateuser WHERE email=$1 AND fc=$2";
    const values = [req.body.email, req.body.fc];
    return await db.query(text, values);
}


//checks if a given request exists in the db
async function checkReqExistance(req) {
    const text = "SELECT status FROM singlerequest WHERE req_id=$1";
    const values = [req.body.reqID];
    const rows = await db.query(text, values);

    return rows.rowCount>0 && rows.rows[0].status==='pending';
}


//checks if there is a pending request from a given ThirdParty to a given PrivateUser
async function checkPendingRequests(userID, req) {
    const text = "SELECT * FROM singlerequest WHERE sender_id=$1 AND receiver_id=$2 AND status=$3";
    const values = [userID, (await getUserIDByEmail(req)).rows[0].userid, 'pending'];
    const rows = await db.query(text, values);

    return rows.rowCount>0
}


//evaluates the total number of requests in the database, and generates the reqID
async function getReqID() {
    let id = 0;

    let rows = await db.query( 'SELECT count(*) as reqID FROM singlerequest');
    id+= +rows.rows[0].reqid;

    rows = await db.query( 'SELECT count(*) as reqID FROM grouprequest');
    id+= +rows.rows[0].reqid;

    return (id+1).toString();
}


//retrieve dataTypes of the request
async function getRequestContent(req) {
    const text = "SELECT datatype FROM requestcontent WHERE req_id = $1";
    const values = [req.body.reqID];
    return (await db.query(text, values)).rows;
}



module.exports = router;
