const client = require('../settings/dbconnection');


const registerSingle = (body, res) => {
    if (checkRegistration('PrivateUser', body.email, res))
        res.status(401).send('Already registered');
    else
        res.send(200);

};

function checkRegistration(table, email) {
    let text;
    if(table==='PrivateUser') text = 'SELECT * FROM PrivateUser WHERE email = $1';
    else text = 'SELECT * FROM ThirdPartyUser WHERE email = $1';
    const values = [email];

    client.query(text, values, (err, response) => {
        return !!(err || response.rowCount !== 0);
    })
}

module.exports = registerSingle;