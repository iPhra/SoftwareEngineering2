const express = require('express');

const app = express();


require('./startup/logging')(app);
require('./startup/validator')(app);
require('./startup/routes')(app);
require('./startup/prod')(app);



module.exports = app;