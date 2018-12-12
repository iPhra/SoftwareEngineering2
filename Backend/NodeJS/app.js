const express = require('express');
const logger = require('morgan');

const mountRoutes = require('./routes/index');

const app = express();

app.use(logger('dev')); //logs each request received
app.use(express.json()); //use json as format for requests
app.use(express.urlencoded({ extended: false }));
mountRoutes(app);



module.exports = app;


