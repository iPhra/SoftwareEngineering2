const validator = require('../middlewares/validator');
const express = require('express');


module.exports = (app) => {
    app.use(express.json()); //use json as format for requests
    app.use(express.urlencoded({ extended: false }));
    app.use(validator())
};