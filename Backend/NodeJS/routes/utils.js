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


//returns the userID of the PrivateUser associated to the email
async function getUserByEmail(email) {
    const text = 'SELECT userid FROM PrivateUser WHERE email = $1';
    const res = await db.query(text, [email]);
    return res.rows[0].userid;
}



module.exports.logError = logError;
module.exports.isThirdParty = isThirdParty;
module.exports.isPrivateUser = isPrivateUser;
module.exports.getUserByEmail = getUserByEmail;