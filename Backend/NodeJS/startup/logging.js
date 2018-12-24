const config = require('config');
const logger = require('morgan');
require('express-async-errors');


module.exports = (app) => {
    app.use(logger('dev')); //logs each request received

    //catch exceptions that weren't caught properly in a block
    process.on('uncaughtException', (ex) => {
        console.log("Uncaught exception: " + ex);
        process.exit(1)
    });

    //catch rejections that weren't caught properly in a block
    process.on('unhandledRejection', (ex) => {
        console.log("Unhandled rejection: " + ex);
        process.exit(1)
    });

    if (!config.get('jwtPrivateKey')) {
        console.error("FATAL ERROR: jwtPrivateKey not defined, please export the environmental variable");
        process.exit(1)
    }
};