const express = require('express');
const logger = require('morgan');
const validator = require('./middlewares/validator');
const mountRoutes = require('./routes/index');

const app = express();

app.use(logger('dev')); //logs each request received
app.use(express.json()); //use json as format for requests
app.use(express.urlencoded({ extended: false }));
app.use(validator()); //validate each request using Joi
mountRoutes(app);



module.exports = app;


