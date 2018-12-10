const db = require('../settings/dbconnection');

//Logs an error thrown when a query fails, and sends a HTTP 400 response
function logError(error, res) {
    console.log(error);
    res.status(400).send('Query error');
}

async function isThirdParty(userID) {
    text = 'SELECT * FROM ThirdParty WHERE userID = $1';
    res = await db.query(text, [userID]);
    return res.rowCount===1
}

async function isPrivateUser(userID) {
    text = 'SELECT * FROM PrivateUser WHERE userID = $1';
    res = await db.query(text, [userID]);
    return res.rowCount===1
}

module.exports.logError = logError;
module.exports.isThirdParty = isThirdParty;
module.exports.isPrivateUser = isPrivateUser;