const Joi = require('joi');

//@todo validate birthdate so it's only a DD-MM-YYY format

const email = Joi.string().email().required();
const password = Joi.string().min(8).required();

const singleRegSchema = {
    email: email,
    password: password,
    fc: Joi.string().length(9).required(),
    full_name: Joi.string().required(),
    birthdate:  Joi.date().required(),
    sex: Joi.string().valid(['M','F','U']).required(),
};

const thirdRegSchema = {
    email: email,
    password: password,
    piva: Joi.string().length(11).required(),
    company_name: Joi.string().required(),
    company_description:  Joi.string().max(30),
};

const login = {
    email: email,
    password: password
};

module.exports = {
    '/reg/single' : singleRegSchema,
    '/reg/tp' : thirdRegSchema,
    '/login' : login
};

