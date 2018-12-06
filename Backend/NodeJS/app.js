const express = require('express');
const logger = require('morgan');

const indexRouter = require('./routes/index');
const authRouter = require('./routes/auth');

const app = express();
const client = require('./settings/dbconnection');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));


app.use('/', indexRouter);
app.use('/auth', authRouter);


module.exports = app;
