const db = require('../settings/dbconnection');


//logs an error thrown when a query fails, and sends a HTTP 400 response
function logError(error, res) {
    console.log(error);
    res.status(400).send({error: 'Query error'});
}


//true if the given userID is a ThirdParty
async function isThirdParty(userID) {
    const text = 'SELECT * FROM ThirdParty WHERE userID = $1';
    const res = await db.query(text, [userID]);
    return res.rowCount>0
}


//true if the given userID is a PrivateUser
async function isPrivateUser(userID) {
    const text = 'SELECT * FROM PrivateUser WHERE userID = $1';
    const res = await db.query(text, [userID]);
    return res.rowCount>0
}


//checks if a given PrivateUser exists in the db, given his email and fc, and returns the result of the query
async function getUserIDByEmail(req) {
    const text = "SELECT userid FROM privateuser WHERE email=$1 AND fc=$2";
    const values = [req.body.email, req.body.fc];
    return await db.query(text, values);
}


//given a date, adds the given number of days to that date
function addDays(date, days) {
    date = new Date(date);
    date.setDate(date.getDate() + days);
    return date;
}



module.exports.logError = logError;
module.exports.isThirdParty = isThirdParty;
module.exports.isPrivateUser = isPrivateUser;
module.exports.getUserIDByEmail = getUserIDByEmail;
module.exports.addDays = addDays;