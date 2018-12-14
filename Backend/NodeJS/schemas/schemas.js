//@todo Aggiungere validation a birthdate per controllare sia nel formato DDMMYYYY
//@todo Aggiungere validation che i due array in dataSettings siano lunghi uguali
//@todo Aggiungere che duration può esserci solo se c'è subscribing a true


const Joi = require('joi');
const email = Joi.string().email().max(40).required();
const fc = Joi.string().length(9).required();
const password = Joi.string().min(8).max(20);
const authToken = Joi.string().required();
const full_name = Joi.string().max(30);
const birthdate = Joi.date().min("1-1-1900");
const sex = Joi.string().valid(['M','F','U']);
const dataTypes = Joi.string().valid(['standinghours','heartrate','distancewalkingrunning','sleepinghours', 'weight', 'height', 'age', 'activeenergy', 'steps']);
const company_name = Joi.string().max(20);
const company_description = Joi.string().max(100);
const types = Joi.array().items(dataTypes).required();


const singleRegSchema = {
    email: email,
    password: password.required(),
    fc: fc,
    full_name: full_name.required(),
    birthdate: birthdate.required(),
    sex: sex.required(),
};

const thirdRegSchema = {
    email: email,
    password: password.required(),
    piva: Joi.string().length(11).required(),
    company_name: company_name.required(),
    company_description: company_description,
};

const login = {
    email: email,
    password: password
};

const singleSettings = {
    authToken : authToken,
    password : password,
    full_name : full_name,
    birthdate : birthdate,
};

const tpSettings = {
    authToken : authToken,
    password : password,
    company_name : company_name,
    company_description : company_description,
};

const dataSettings = {
    authToken : authToken,
    types : types,
    enabled : Joi.array().items(Joi.boolean()).required(),
};

const dataImport = {
    authToken : authToken,
    types : types,
    values : Joi.array().items(Joi.number()).required(),
    timestamps: Joi.array().items(Joi.date().iso()).required(),
};

const dataStats = {
    authToken : authToken,
    types : types,
};

const singleReq = {
    authToken : authToken,
    email: email,
    fc: fc,
    types: types,
    subscribing: Joi.boolean().default(false),
    duration: Joi.number(),
};

const acceptReq = {
    authToken : authToken,
    reqID : Joi.string().required(),
    choice : Joi.boolean(),
};

const downloadReq = {
    authToken : authToken,
    reqID : Joi.string().required(),
};


module.exports = {
    '/reg/single' : singleRegSchema,
    '/reg/tp' : thirdRegSchema,
    '/login' : login,
    '/single/info' : singleSettings,
    '/tp/info' : tpSettings,
    '/single/data' : dataSettings,
    '/upload' : dataImport,
    '/stats' : dataStats,
    '/tp/sendSingle' : singleReq,
    '/single/choice' : acceptReq,
    '/tp/downloadSingle' : downloadReq,
    '/tp/downloadGroup' : downloadReq
};

