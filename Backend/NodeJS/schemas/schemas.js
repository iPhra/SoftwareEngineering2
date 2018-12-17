//@todo Aggiungere validation a birthdate per controllare sia nel formato DDMMYYYY
//@todo Aggiungere che duration può esserci solo se c'è subscribing a true


const Joi = require('joi');
const email = Joi.string().email().max(40).required();
const fc = Joi.string().length(16).required();
const password = Joi.string().min(8).max(20);
const full_name = Joi.string().max(30);
const birthdate = Joi.date().min("1-1-1900");
const sex = Joi.string().valid(['M','F','U']);
const dataTypes = Joi.string().valid(['standinghours','heartrate','distancewalkingrunning','sleepinghours', 'weight', 'height', 'age', 'activeenergy', 'steps']);
const company_name = Joi.string().max(20);
const company_description = Joi.string().max(100);
const types = Joi.array().items(dataTypes).max(50).required();
const subscribing = Joi.boolean().default(false);
const duration = Joi.any().when('subscribing', { is: true, then: Joi.number().integer().default(1), otherwise: Joi.any().forbidden()}); //by default it's a one day subscription


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
    password : password,
    full_name : full_name,
    birthdate : birthdate,
};

const tpSettings = {
    password : password,
    company_name : company_name,
    company_description : company_description,
};

const dataSettings = Joi.object({
    types : types,
    enabled : Joi.array().items(Joi.boolean()).required(),
}).assert('types.length',Joi.ref('enabled.length'));

const dataImport = Joi.object({
    types : types,
    values : Joi.array().items(Joi.array().items(Joi.number())).required(),
    timestamps: Joi.array().items(Joi.array().items(Joi.date().iso())).required(),
}).assert('types.length',Joi.ref('values.length')).assert('types.length',Joi.ref('timestamps.length'));

const dataStats = {
    types : types,
};

const singleReq = {
    email: Joi.string().email().max(40),
    fc: Joi.string().length(16),
    types: types,
    subscribing: subscribing,
    duration: duration,
};

const groupReq = Joi.object({
    types: types,
    parameters: Joi.array().items(dataTypes).required(),
    bounds : Joi.array().items(Joi.object().keys({
        lowerbound: Joi.number(),
        upperbound: Joi.number()
    })).required(),
    subscribing: subscribing,
    duration: duration,
}).assert('parameters.length',Joi.ref('bounds.length'));

const acceptReq = {
    reqID : Joi.number().integer().required(),
    choice : Joi.boolean().required(),
};

const downloadReq = {
    reqID : Joi.number().integer().required(),
};



module.exports = {
    '/auth/reg/single' : singleRegSchema,
    '/auth/reg/tp' : thirdRegSchema,
    '/auth/login' : login,
    '/settings/single/info' : singleSettings,
    '/settings/tp/info' : tpSettings,
    '/settings/single/data' : dataSettings,
    '/data/upload' : dataImport,
    '/data/stats' : dataStats,
    '/req/tp/sendSingle' : singleReq,
    '/req/tp/sendGroup' : groupReq,
    '/req/single/choice' : acceptReq,
    '/req/tp/downloadSingle' : downloadReq,
    '/req/tp/downloadGroup' : downloadReq
};

