const _ = require('lodash');
const Joi = require('joi');
const Schemas = require('../schemas/schemas');

module.exports = () => {
    // enabled HTTP methods for request data validation
    const _supportedMethods = ['post'];

    // Joi validation options
    const _validationOptions = {
        abortEarly: false, // abort after the last validation error
        allowUnknown: false, // allow unknown keys that will be ignored
        stripUnknown: true // remove unknown keys from the validated data
    };

    // return the validation middleware
    return (req, res, next) => {

        const route = req.url;
        const method = req.method.toLowerCase();

        if (_.includes(_supportedMethods, method) && _.has(Schemas, route)) {

            // get schema for the current route
            const _schema = _.get(Schemas, route);

            if (_schema) {

                // Validate req.body using the schema and validation options
                return Joi.validate(req.body, _schema, _validationOptions, (err) => {

                    if (err) {
                        console.log(err);
                        res.status(400).send({error: "Malformed Request"});

                    } else {
                        next();
                    }

                });
            }
        }

        next();
    };
};