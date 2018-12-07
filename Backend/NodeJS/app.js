const express = require('express');
const logger = require('morgan');

const mountRoutes = require('./routes/index');

const app = express();

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
mountRoutes(app);


module.exports = app;


