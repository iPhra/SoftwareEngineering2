const helmet = require('helmet');
const compression = require('compression');


module.exports = (app) => {
    app.use(helmet()); //security middleware
    app.use(compression()) //compresses http response
};