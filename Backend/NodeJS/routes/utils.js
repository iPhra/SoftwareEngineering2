const db = require('../settings/dbconnection');
const bcrypt = require('bcryptjs');


//logs an error thrown when a query fails, and sends a HTTP 400 response
function logError(error, res) {
    console.log(error);
    res.status(400).send({error: 'Query error'});
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


//hashes the password
async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}



module.exports.logError = logError;
module.exports.getUserIDByEmail = getUserIDByEmail;
module.exports.addDays = addDays;
module.exports.hashPassword = hashPassword;