const db = require('../settings/dbconnection');
const bcrypt = require('bcryptjs');


//logs an error thrown when a query fails, and sends a HTTP 400 response
function logError(error, res) {
    console.log(error);
    res.status(400).send({error: 'Query error'});
}


//checks if a given PrivateUser exists in the db, given his email, and returns the result of the query
async function getUserIDByEmail(req) {
    const text = "SELECT userid FROM privateuser WHERE email=$1";
    const values = [req.body.email];
    return await db.query(text, values);
}


//checks if a given PrivateUser exists in the db, given his fc, and returns the result of the query
async function getUserIDByFC(req) {
    const text = "SELECT userid FROM privateuser WHERE fc=$1";
    const values = [req.body.fc];
    return await db.query(text, values);
}


//given a date, adds the given number of days to that date
function addDays(date, days) {
    date = new Date(date);
    date.setDate(date.getDate() + days);
    return date;
}


//hashes the password
async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}


//generate authToken
function getActivToken(userID) {
    let text = userID.toString();
    const possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (let i = 0; i < 10; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}


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


//evaluates the total number of requests in the database, and generates the reqID
async function getReqID() {
    let id = 0;

    let rows = await db.query( 'SELECT count(*) as reqID FROM singlerequest');
    id+= +rows.rows[0].reqid;

    rows = await db.query( 'SELECT count(*) as reqID FROM grouprequest');
    id+= +rows.rows[0].reqid;

    return (id+1).toString();
}


//checks that at least 1000 users exist matching the search parameters
async function getTargetUsers(parameters, req_date) {
    let unique = [];
    let text;
    let values;
    let users;

    for(let i=0; i<parameters.length; i++) {

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

        for(let j=0; j<users.rowCount; j++) {
            unique.push(users.rows[j].userid);
        }
    }

    return unique
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

    if(rows.rows[0].subscribing) final_date = addDays(rows.rows[0].req_date, rows.rows[0].duration);
    else final_date = rows.rows[0].req_date;

    return final_date
}


//sets the result of a group request
async function setChoice(choice, req_id) {
    let text = "UPDATE grouprequest SET status=$1 WHERE req_id = $2";
    let values = [choice, req_id];
    await db.query(text, values)
}



module.exports.logError = logError;
module.exports.getUserIDByEmail = getUserIDByEmail;
module.exports.getUserIDByFC = getUserIDByFC;
module.exports.addDays = addDays;
module.exports.hashPassword = hashPassword;
module.exports.getAuthToken = getActivToken;
module.exports.checkReqExistance = checkReqExistance;
module.exports.checkPendingSingleRequests = checkPendingSingleRequests;
module.exports.checkPendingGroupRequests = checkPendingGroupRequests;
module.exports.getReqID = getReqID;
module.exports.setChoice = setChoice;
module.exports.getFinalDate = getFinalDate;
module.exports.getRequestParameters = getRequestParameters;
module.exports.getRequestTypes = getRequestTypes;
module.exports.getTargetUsers = getTargetUsers;