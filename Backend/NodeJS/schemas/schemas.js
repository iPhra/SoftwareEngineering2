const Joi = require('joi');

const singleRegSchema = {
    name: Joi.string().min(3).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    FC: Joi.string().length(16).required(),
    full_name: Joi.string().required(),
    birthdate:  Joi.date().required(),
    sex: Joi.string().valid(['M','F','U']).required(),
};

module.exports = {
    '/reg/single' : singleRegSchema
};

