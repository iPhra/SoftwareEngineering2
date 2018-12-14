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
        if(await checkPendingSingleRequests(userID, req)) {
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


router.post('/tp/sendGroup', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a ThirdParty
        if (!isLogged(req.body.authToken) || !(await isThirdParty(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //if there's a pending request already from the TP to the PU
        if(await checkPendingGroupRequests(userID)) {
            res.status(403).send({error: "There already is a pending request"});
            return
        }

        //insert request into GroupRequest table
        let i;
        const reqID = await getReqID();
        const today = new Date().toISOString().slice(0, 10);
        //if the user is subscribing and the duration is not specified, then it's one month by default, otherwhise it's the given value
        const duration = req.body.subscribing ? (req.body.duration? req.body.duration : 30) : null;
        let text = 'INSERT INTO grouprequest VALUES($1, $2, $3, $4, $5, $6)';
        let values = [reqID, userID, req.body.subscribing, "pending", duration, today];
        await db.query(text, values);

        //for each type, insert the type into RequestContent table
        for(i=0; i<req.body.types.length; i++) {
            text = "INSERT INTO requestcontent VALUES($1, $2)";
            values = [reqID, req.body.types[i]];
            await db.query(text, values);
        }

        //for each type, insert the parameters and the bounds into SearchParameter table
        for(i=0; i<req.body.parameters.length; i++) {
            text = "INSERT INTO searchparameter VALUES($1, $2, $3, $4)";
            values = [reqID, req.body.parameters[i], req.body.bounds[i][0], req.body.bounds[i][1]];
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

        //retrieve data types
        let types = await getRequestTypes(req);

        const final_date = getFinalDate(rows);
        const receiver_id = rows.rows[0].receiver_id;
        let response = [];
        let i;

        //retrieve the value imported by the user for each datatype, and build the response
        for(i=0; i<types.length; i++) {
            text = "SELECT value, timest FROM userdata WHERE userid = $1 and datatype = $2 and timest::date <= $3";
            values = [receiver_id, types[i].datatype, final_date];
            rows = await db.query(text, values);

            response[types[i].datatype] = rows.rows
        }

        res.status(200).send({data: response});
    } catch(error) {
        return logError(error, res)
    }
});


router.post('/tp/downloadGroup', validateRequest, async (req, res) => {
    let userID = getUserIDByToken(req.body.authToken);

    try {

        //if he's not logged in or he's not a ThirdParty
        if (!isLogged(req.body.authToken) || !(await isThirdParty(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //retrieve the request
        let text = "SELECT * FROM grouprequest WHERE req_id = $1";
        let values = [req.body.reqID];
        let rows = await db.query(text, values);

        //if the request is not present or if it was not approved
        if(rows.rowCount===0) {
            res.status(403).send({error: "Request does not exist"});
            return
        }

        //retrieve data types and search parameters
        let types = await getRequestTypes(req);
        let parameters = await getRequestParameters(req);

        let i;
        const final_date = getFinalDate(rows);

        //check that at least 1000 users exist matching the search parameters
        if(!(await checkGroupCondition(parameters, final_date))) {
            res.status(403).send({error: "Less than 1000 users match the search parameters"});
            return;
        }

        //@todo add data retrieval

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
            res.status(403).send({error: "Request does not exist or is not pending"});
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

        //get all the requests addressing the user
        let text = 'SELECT * FROM singlerequest WHERE receiver_id = $1';
        let values = [userID];
        let requests = await db.query(text, values);

        let datatypes;
        let thirdparty;
        let i;
        let obj;
        let result = [];

        //for every request get the sender and the datatype requested, and build the response
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


router.get('/tp/list', async (req, res) => {
    let userID = getUserIDByToken(req.query.authToken);

    try {

        //if he's not logged in or he's not a ThirdParty
        if (!isLogged(req.query.authToken) || !(await isThirdParty(userID))) {
            res.status(403).send({error: "Wrong authentication"});
            return
        }

        //get all the single requests of the user
        let text = 'SELECT * FROM singlerequest WHERE sender_id = $1';
        let values = [userID];
        let singlerequests = await db.query(text, values);

        let datatypes;
        let privateuser;
        let i;
        let obj;
        let single = [];

        //for every single request get the receiver and the datatype requested, and build the response
        for(i=0; i<singlerequests.rowCount; i++) {

            //receiver
            text = 'SELECT * FROM privateuser WHERE userid = $1';
            values = [singlerequests.rows[i].receiver_id];
            privateuser = await db.query(text, values);

            //datatype
            text = 'SELECT datatype FROM requestcontent WHERE req_id = $1';
            values = [singlerequests.rows[i].req_id];
            datatypes = await db.query(text, values);

            obj = {
                "reqid" : singlerequests.rows[i].req_id,
                "email" : privateuser.rows[0].email,
                "fc" : privateuser.rows[0].fc,
                "types" : datatypes.rows,
                "status" : singlerequests.rows[i].status,
                "subscribing" : singlerequests.rows[i].subscribing,
                "duration" : singlerequests.rows[i].duration
            };

            single.push(obj);
        }

        //get all the group requests of the user
        text = 'SELECT * FROM grouprequest WHERE sender_id = $1';
        values = [userID];
        let grouprequests = await db.query(text, values);

        let searchparameters;
        let group = [];

        //for every group request get the search parameters and the data types requested, and build the response
        for(i=0; i<grouprequests.rowCount; i++) {

            //datatype
            text = 'SELECT datatype FROM requestcontent WHERE req_id = $1';
            values = [grouprequests.rows[i].req_id];
            datatypes = await db.query(text, values);

            //search parameters
            text = 'SELECT datatype, upperbound, lowerbound FROM searchparameter WHERE req_id = $1';
            values = [grouprequests.rows[i].req_id];
            searchparameters = await db.query(text, values);

            obj = {
                "reqid" : grouprequests.rows[i].req_id,
                "types" : datatypes.rows,
                "parameters" : searchparameters.rows,
                "status" : grouprequests.rows[i].status,
                "subscribing" : grouprequests.rows[i].subscribing,
                "duration" : grouprequests.rows[i].duration
            };

            group.push(obj);
        }

        res.status(200).send({requests: {
            "single" : single,
                "group" : group
            }});
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
async function checkPendingSingleRequests(userID, req) {
    const text = "SELECT * FROM singlerequest WHERE sender_id=$1 AND receiver_id=$2 AND status=$3";
    const values = [userID, (await getUserIDByEmail(req)).rows[0].userid, 'pending'];
    const rows = await db.query(text, values);

    return rows.rowCount>0
}


//checks if there is a pending request from a given ThirdParty to a given PrivateUser
async function checkPendingGroupRequests(userID) {
    const text = "SELECT * FROM grouprequest WHERE sender_id=$1 AND status=$2";
    const values = [userID, 'pending'];
    const rows = await db.query(text, values);

    return rows.rowCount>0
}


//checks that at least 1000 users exist matching the search parameters
async function checkGroupCondition(parameters, req_date) {
    let unique = 0;
    let i;
    let text;
    let values;

    for(i=0; i<parameters.length; i++) {
        text = "SELECT count(distinct(userid)) as n FROM userdata WHERE datatype=$1 and timest::date<=$2 and value>$3 and value<$4 ";
        values = [parameters[i].datatype, req_date, parameters[i].lowerbound, parameters[i].upperbound];
        unique += (await db.query(text, values)).rows[0].n;
    }

    return unique>=1000
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
async function getRequestTypes(req) {
    const text = "SELECT datatype FROM requestcontent WHERE req_id = $1";
    const values = [req.body.reqID];
    return (await db.query(text, values)).rows;
}


//retrieve search parameters of the request
async function getRequestParameters(req) {
    const text = "SELECT datatype, lowerbound, upperbound FROM searchparameter WHERE req_id = $1";
    const values = [req.body.reqID];
    return (await db.query(text, values)).rows;
}


//given a date, adds the given number of days to that date
function addDays(date, days) {
    date = new Date(date);
    date.setDate(date.getDate() + days);
    return date;
}


//if the ThirdParty is subscribed, the requests lasts until the end of the subscription (duration + date), otherwhise until the day of the request
function getFinalDate(rows) {
    let final_date;
    if(rows.rows[0].subscribing) {
        final_date = addDays(rows.rows[0].req_date, rows.rows[0].duration);
    }
    else {
        final_date = rows.rows[0].req_date;
    }
    return final_date
}



module.exports = router;
