const bcrypt = require('bcryptjs');


//hashes the password
async function hashPassword(password) {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
}

//given a date, adds the given number of days to that date
function addDays(date, days) {
    date = new Date(date);
    date.setDate(date.getDate() + days);
    return date;
}



module.exports.hashPassword = hashPassword;
module.exports.addDays = addDays;
