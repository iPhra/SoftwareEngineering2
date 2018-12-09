const Joi = require('joi');

//@todo Aggiungere validation a birthdate per controllare sia nel formato DDMMYYYY

const email = Joi.string().email().max(40).required();
const password = Joi.string().min(8).max(20).required();

const singleRegSchema = {
    email: email,
    password: password,
    fc: Joi.string().length(9).required(),
    full_name: Joi.string().max(30).required(),
    birthdate:  Joi.date().min("1-1-1900").required(),
    sex: Joi.string().valid(['M','F','U']).required(),
};

const thirdRegSchema = {
    email: email,
    password: password,
    piva: Joi.string().length(11).required(),
    company_name: Joi.string().max(20).required(),
    company_description:  Joi.string().max(100),
};

const login = {
    email: email,
    password: password
};

const singleSettings = {
    authToken : Joi.string().required(),
    password : Joi.string().min(8).max(20),
    full_name : Joi.string().max(30),
    birthdate : Joi.date().min("1-1-1900"),
    sex: Joi.string().valid(['M','F','U']),
};

module.exports = {
    '/reg/single' : singleRegSchema,
    '/reg/tp' : thirdRegSchema,
    '/login' : login,
    '/single/info' : singleSettings
};

