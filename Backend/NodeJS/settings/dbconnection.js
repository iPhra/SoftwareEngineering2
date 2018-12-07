const { Pool } = require('pg');

const pool = new Pool({
    host : "d4h.cxxsbhqgk33o.eu-central-1.rds.amazonaws.com",
    port : "5432",
    user: "LorenzoMolteniNegri",
    password: "colombetti",
    database: "d4h"
});

module.exports = {
    query: (text, params) => pool.query(text, params)
};