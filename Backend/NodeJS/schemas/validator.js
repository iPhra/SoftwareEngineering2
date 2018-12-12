const _ = require('lodash');
const Joi = require('joi');
const Schemas = require('./schemas');

module.exports = () => {
    // enabled HTTP methods for request data validation
    const _supportedMethods = ['post', 'get'];

    // Joi validation options
    const _validationOptions = {
        abortEarly: false, // abort after the last validation error
        allowUnknown: false, // allow unknown keys that will be ignored
        stripUnknown: true // remove unknown keys from the validated data
    };

    // return the validation middleware
    return (req, res, next) => {

        const route = req.route.path;
        const method = req.method.toLowerCase();

        if (_.includes(_supportedMethods, method) && _.has(Schemas, route)) {

            // get schema for the current route
            const _schema = _.get(Schemas, route);

            if (_schema) {

                // Validate req.body using the schema and validation options
                return Joi.validate(req.body, _schema, _validationOptions, (err) => {

                    if (err) {
                        console.log(err);
                        res.status(400).json({error: "Malformed Request"});

                    } else {
                        next();
                    }

                });
            }
        }

        next();
    };
};