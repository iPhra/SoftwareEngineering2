//@todo Rivedere codici d'errore (anche sul resto del progetto!)
//@todo Gestire i rollback!

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

        const receiver_id = await getUserIDByEmail(req);

        //if the receiving user does not exist
        if (receiver_id.rowCount===0) {
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
        //if the user is subscribing and the duration is not specified, then it's one month by default, otherwhise it's the given value
        const duration = req.body.subscribing ? (req.body.duration? req.body.duration : 30) : null;
        let text = 'INSERT INTO singlerequest VALUES($1, $2, $3, $4, $5, $6, $7)';
        let values = [reqID, userID, receiver_id.rows[0].userid, req.body.subscribing, "pending", duration, today];
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
        let req_date;
        let response = {};
        const receiver_id = rows.rows[0].receiver_id;

        //if the ThirdParty is subscribed, i return all data availabe until the end of the subscription (duration + date)
        if(rows.rows[0].subscribing) {
            text = "SELECT value, timest FROM userdata WHERE userid = $1 and datatype = $2 and timest::date <= $3";
            req_date = addDays(rows.rows[0].req_date, rows.rows[0].duration);
        }
        //otherwise, i return all data available until the day of the subscription
        else {
            text = "SELECT value, timest FROM userdata WHERE userid = $1 AND datatype = $2 and timest::date <= $3";
            req_date = rows.rows[0].req_date;
        }

        for(i=0; i<dataTypes.length; i++) {
            values = [receiver_id, dataTypes[i].datatype, req_date];
            rows = await db.query(text, values);

            response[dataTypes[i].datatype] = rows.rows
        }

        res.status(200).send({data: response});
    } catch(error) {
        return logError(error, res)
    }
});


router.post('/single/choice', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a PrivateUser
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

        res.status(200).send({message: "Action successful"});
    } catch(error) {
        return logError(error, res)
    }
});


router.get('/single/list', async (req, res) => {
    let userID = getUserIDByToken(req.query.authToken);

    try {

        //if he's not logged in or he's not a PrivateUser
        if (!isLogged(req.query.authToken) || !(await isPrivateUser(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //get all the requests
        let text = 'SELECT * FROM singlerequest WHERE receiver_id = $1';
        let values = [userID];
        let requests = await db.query(text, values);
        let datatypes;
        let thirdparty;
        let i;
        let obj;
        let result = [];

        //for every request
        for(i=0; i<requests.rowCount; i++) {

            text = 'SELECT * FROM thirdparty WHERE userid = $1';
            values = [requests.rows[i].sender_id];
            thirdparty = await db.query(text, values);

            text = 'SELECT datatype FROM requestcontent WHERE req_id = $1';
            values = [requests.rows[i].req_id];
            datatypes = await db.query(text, values);

            obj = {
                "reqid" : requests.rows[i].req_id,
                "email" : thirdparty.rows[0].email,
                "piva" : thirdparty.rows[0].piva,
                "company_name" : thirdparty.rows[0].company_name,
                "types" : datatypes.rows,
                "status" : requests.rows[i].status,
                "subscribing" : requests.rows[i].subscribing,
                "duration" : requests.rows[i].duration
            };

            result.push(obj);
        }

        res.status(200).send({requests: result});
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


function addDays(date, days) {
    date = new Date(date);
    date.setDate(date.getDate() + days);
    return date;
}



module.exports = router;
