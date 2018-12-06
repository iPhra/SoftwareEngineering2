const {Client} = require('pg');

const client = new Client({
    host : "d4h.cxxsbhqgk33o.eu-central-1.rds.amazonaws.com",
    port : "5432",
    user: "LorenzoMolteniNegri",
    password: "colombetti",
    database: "d4h"
});

client.connect((err) => {
    if (err) {
        console.error(err)
    }
    else {
        console.log('Database connection successful')
    }
});

module.exports = client;