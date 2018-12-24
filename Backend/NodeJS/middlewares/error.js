const winston = require('winston');
const db = require('../settings/dbconnection');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    defaultMeta: {service: 'user-service'},
    transports: [
        new winston.transports.File({ filename: 'utils/error.log', level: 'error' }),
        new winston.transports.File({ filename: 'utils/combined.log' }),
        new winston.transports.Console({level: 'error'})
    ]
});



module.exports = async (err, req, res, next) => {
    logger.error(err.message, err);
    res.status(400).send({error: "Query error"});

    try {
        await(db.query('ROLLBACK'));
    }
    catch(error) {
        logger.error("Could not rollback: " + err.message.err);
    }
};