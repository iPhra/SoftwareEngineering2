//@todo Cambiare come controllo i 1000 account delle group request (magari controllando l'ultimo valore inserito)

const Router = require('express-promise-router');
const db = require('../settings/dbconnection');
const utils = require('./utils');
const authenticator = require('../middlewares/authenticator');

const logError = utils.logError;
const getUserIDByEmail = utils.getUserIDByEmail;
const getUserIDByFC = utils.getUserIDByFC;
const addDays = utils.addDays;
const router = new Router();


router.post('/tp/sendSingle', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="ThirdParty")
            return res.status(401).send({error: "You need to login with a Third Party account"});

        const receiver_id = req.body.email? await getUserIDByEmail(req) : await getUserIDByFC(req);

        //if the receiving user does not exist
        if (receiver_id.rowCount===0)
            return res.status(403).send({error: "Target user does not exist"});

        //if there's a pending request already from the TP to the PU
        if(await checkPendingSingleRequests(userID, receiver_id))
            return res.status(403).send({error: "There already is a pending request"});

        await(db.query('BEGIN'));

        //insert request into SingleRequest table
        let i;
        const reqID = await getReqID();
        const today = new Date().toISOString().slice(0, 10);
        let text = 'INSERT INTO singlerequest VALUES($1, $2, $3, $4, $5, $6, $7)';
        let values = [reqID, userID, receiver_id.rows[0].userid, req.body.subscribing, "pending", req.body.duration, today];
        await db.query(text, values);

        //for each type, insert the type into RequestContent table
        for(i=0; i<req.body.types.length; i++) {
            text = "INSERT INTO requestcontent VALUES($1, $2)";
            values = [reqID, req.body.types[i]];
            await db.query(text, values);
        }

        await(db.query('COMMIT'));
        res.status(200).send({message: "Request sent"});
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }
});


router.post('/tp/sendGroup', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="ThirdParty")
            return res.status(401).send({error: "You need to login with a Third Party account"});

        //if there's a pending request already from the TP to the PU
        if(await checkPendingGroupRequests(userID))
            return res.status(403).send({error: "There already is a pending request"});

        await(db.query('BEGIN'));

        //insert request into GroupRequest table
        let i;
        const reqID = await getReqID();
        const today = new Date().toISOString().slice(0, 10);
        let text = 'INSERT INTO grouprequest VALUES($1, $2, $3, $4, $5, $6)';
        let values = [reqID, userID, req.body.subscribing, "pending", req.body.duration, today];
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
            values = [reqID, req.body.parameters[i], req.body.bounds[i].lowerbound, req.body.bounds[i].upperbound];
            await db.query(text, values);
        }

        await(db.query('COMMIT'));
        res.status(200).send({message: "Request sent"});
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }
});


router.post('/tp/downloadSingle', authenticator(), async (req, res) => {

    try {

        //if he's not logged in or he's not a ThirdParty
        if (req.body.usertype!=="ThirdParty")
            res.status(401).send({error: "You need to login with a Third Party account"});

        //retrieve status of the request
        let text = "SELECT * FROM singlerequest WHERE req_id = $1";
        let values = [req.body.reqID];
        let rows = await db.query(text, values);

        //if the request is not present or if it was not approved
        if(rows.rowCount===0 || rows.rows[0].status!== 'accepted')
            return res.status(403).send({error: "Can't download data"});

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


router.post('/tp/downloadGroup', authenticator(), async (req, res) => {
    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="ThirdParty")
            return res.status(401).send({error: "You need to login with a Third Party account"});

        //retrieve the request
        let text = "SELECT * FROM grouprequest WHERE req_id = $1";
        let values = [req.body.reqID];
        let rows = await db.query(text, values);

        //if the request is not present
        if(rows.rowCount===0)
            return res.status(403).send({error: "Request does not exist"});

        const req_id = rows.rows[0].req_id;
        const types = await getRequestTypes(req); //data types of the request
        const parameters = await getRequestParameters(req); //search parameters of the request
        const final_date = getFinalDate(rows); //maximum date allowed for each data point
        const users = await getTargetUsers(parameters, final_date); //get target users matching the search parameters

        //if the target users are less than 1000
        if(users.length <1) {
            await setChoice('refused', req_id);
            res.status(403).send({error: "Less than 1000 users match the search parameters"});
            return;
        }

        let i;
        let j;
        let obj;
        let response = [];

        for(i=0; i<users.length; i++) {

            obj = {
                "userid" : i,
                "data" : []
            };

            for(j=0; j<types.length; j++) {
                text = "SELECT value,timest FROM userdata WHERE userid = $1 and datatype = $2";
                values = [users[i], types[j].datatype];
                rows = await db.query(text, values);

                obj.data.push({
                    "type" : types[j].datatype,
                    "values" : rows.rows
                })
            }

            response.push(obj)

        }

        await setChoice('accepted', req_id);
        res.status(200).send({data: response});
    } catch(error) {
        return logError(error, res)
    }
});


router.post('/single/choice', authenticator(), async (req, res) => {

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="PrivateUser")
            return res.status(401).send({error: "You need to login with a Single User account"});

        //if the request doesn't exist or if it's not pending
        if (!(await checkReqExistance(req)))
            return res.status(403).send({error: "Request does not exist or is not pending"});

        await(db.query('BEGIN'));

        //update the request, if choice is true then the request is accepted
        let text = 'UPDATE singlerequest SET status=$1 WHERE req_id = $2';
        let values = [req.body.choice? 'accepted' : 'refused', req.body.reqID];
        await db.query(text, values);

        await(db.query('COMMIT'));
        res.status(200).send({message: "Action successful"});
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }
});


router.get('/single/list', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="PrivateUser")
            return res.status(401).send({error: "You need to login with a Single User account"});

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
                "duration" : requests.rows[i].duration,
                "req_date" : (requests.rows[i].req_date).toISOString().slice(0,10)
            };

            result.push(obj);
        }

        res.status(200).send({requests: result});
    } catch(error) {
        return logError(error, res)
    }
});


router.get('/tp/list', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="ThirdParty")
            return res.status(401).send({error: "You need to login with a Third Party account"});

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
                "full_name" : privateuser.rows[0].full_name,
                "fc" : privateuser.rows[0].fc,
                "types" : datatypes.rows,
                "status" : singlerequests.rows[i].status,
                "subscribing" : singlerequests.rows[i].subscribing,
                "duration" : singlerequests.rows[i].duration,
                "req_date" : (singlerequests.rows[i].req_date).toISOString().slice(0,10)
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
                "duration" : grouprequests.rows[i].duration,
                "req_date" : (grouprequests.rows[i].req_date).toISOString().slice(0,10)
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


//checks if a given request exists in the db
async function checkReqExistance(req) {
    const text = "SELECT status FROM singlerequest WHERE req_id=$1";
    const values = [req.body.reqID];
    const rows = await db.query(text, values);

    return rows.rowCount>0 && rows.rows[0].status==='pending';
}


//checks if there is a pending request from a given ThirdParty to a given PrivateUser
async function checkPendingSingleRequests(userID, receiver_id) {
    const text = "SELECT * FROM singlerequest WHERE sender_id=$1 AND receiver_id=$2 AND status=$3";
    const values = [userID, receiver_id, 'pending'];
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
async function getTargetUsers(parameters, req_date) {
    let unique = [];
    let i;
    let j;
    let text;
    let values;
    let users;

    for(i=0; i<parameters.length; i++) {

        text = "SELECT distinct(userid) FROM userdata WHERE datatype=$1 and timest::date<=$2";
        values = [parameters[i].datatype, req_date];

        if(parameters[i].lowerbound) {
            text+= " and value>$3";
            values.push(parameters[i].lowerbound);

            if(parameters[i].upperbound) {
                text+= " and value<$4";
                values.push(parameters[i].upperbound)
            }
        }
        else if(parameters[i].upperbound) {
            text+= " and value<$3";
            values.push(parameters[i].upperbound)
        }

        users = await db.query(text, values);

        for(j=0; j<users.rowCount; j++) {
            unique.push(users.rows[j].userid);
        }
    }

    return unique
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


//sets the result of a group request
async function setChoice(choice, req_id) {
    let text = "UPDATE grouprequest SET status=$1 WHERE req_id = $2";
    let values = [choice, req_id];
    await db.query(text, values)
}



module.exports = router;
