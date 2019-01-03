const { Pool } = require('pg');
const config = require('config');


const pool = new Pool(config.get('dbconf'));

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool: pool
};