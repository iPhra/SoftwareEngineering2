const bcrypt = require('bcryptjs');


//hashes the password
async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}



module.exports.hashPassword = hashPassword;
