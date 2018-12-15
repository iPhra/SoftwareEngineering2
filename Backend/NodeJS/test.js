const Joi = require('joi');

const singleReq = Joi.object({
    subscribing: Joi.boolean(),
    duration: Joi.any()
        .when('subscribing', { is: true, then: Joi.number().integer().default(0), otherwise: Joi.any().forbidden()})
});

Joi.validate({
    "subscribing" : true,
}, singleReq, (err, value) => {console.log(err)});