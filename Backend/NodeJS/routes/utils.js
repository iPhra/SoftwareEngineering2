const db = require('../settings/dbconnection');
const bcrypt = require('bcryptjs');


//logs an error thrown when a query fails, and sends a HTTP 400 response
function logError(error, res) {
    console.log(error);
    res.status(400).send({error: 'Query error'});
}


//hashes the password
async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}



module.exports.logError = logError;
module.exports.hashPassword = hashPassword;
