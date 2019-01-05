const Joi = require('joi');
const schemas = require('../../../schemas/schemas');

let result;


//not going to re-test common attributes, they are tested in the first test case that has them
describe('Schemas', () => {

    describe('Private user registration', () => {

        let privateuser;

        beforeEach(() => {
            privateuser = {
                "email" : "extreme_enigma@hotmail.it",
                "password" : "password",
                "fc" : "1234363912333133",
                "full_name" : "Francesco Lorenzo",
                "birthdate" : "1996-08-16",
                "sex" : "M"
            };
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).toBeNull()
        });

        it('Should not validate a wrong password', () => {
            delete privateuser.password;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.password = "2short";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.password = "this password is longer than 20 characters";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.password = 0;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate an incorrect email', () => {
            delete privateuser.email;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.email = 3;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.email = "string longer than 40 characters............................................";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.email = "this is long enough but not an email@test";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate an incorrect fc', () => {
            delete privateuser.fc;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.fc = "string not long 16 characters";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.fc = 1234567891234567;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate an incorrect full name', () => {
            delete privateuser.full_name;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.full_name = "string longer than 30 characters............";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.full_name = 0;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate an incorrect birthdate', () => {
            delete privateuser.birthdate;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.birthdate = "not a date";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.birthdate = "16/08/1996"; //not ISO standard
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.birthdate = "1990/02/12"; //ISO standard
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).toBeNull();
        });

        it('Should not validate an incorrect sex', () => {
            delete privateuser.sex;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.sex = "not a sex";
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();

            privateuser.sex = 0;
            result = Joi.validate(privateuser, schemas["/auth/reg/single"]);
            expect(result.error).not.toBeNull();
        });
    });


    describe('Third Party registration', () => {

        let thirdparty;

        beforeEach(() => {
            thirdparty = {
                "email" : "thirdparty@gmail.com",
                "password" : "password",
                "piva" : "12345678911",
                "company_name" : "Gruosso industries",
                "company_description" : "Test"
            };
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).toBeNull()
        });

        it('Should not validate an incorrect p.iva', () => {
            delete thirdparty.piva;
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();

            thirdparty.piva = "string not long 11 characters";
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();

            thirdparty.piva = 1234567891234567;
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate an incorrect company name', () => {
            delete thirdparty.company_name;
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();

            thirdparty.company_name = "string longer than 20 characters......";
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();

            thirdparty.company_name = 0;
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate an incorrect company description', () => {
            thirdparty.company_description = 0;
            result = Joi.validate(thirdparty, schemas["/auth/reg/tp"]);
            expect(result.error).not.toBeNull();
        });
    });


    describe('Login', () => {

        it('Should validate a well formed schema', () => {
            result = Joi.validate({"email":"test@test.com", "password":"longer than 8 char"}, schemas["/auth/login"]);
            expect(result.error).toBeNull()
        })
    });


    describe('Change private user settings', () => {

        it('Should validate a well formed schema', () => {
            result = Joi.validate({"password":"another password", "full_name":"another name", "birthdate":"2002/12/03"}, schemas["/settings/single/info"]);
            expect(result.error).toBeNull()
        })
    });


    describe('Change third party settings', () => {

        it('Should validate a well formed schema', () => {
            result = Joi.validate({"password":"another password", "company_name":"another name", "company_description":"test"}, schemas["/settings/tp/info"]);
            expect(result.error).toBeNull()
        })
    });


    describe('Import data of a private user', () => {

        let data;

        beforeEach(() => {
            data = {
                "types" : ["heartrate","sleepinghours"],
                "values" : [[98, 7], [8]],
                "timestamps" : [["2008-12-22 08:26:12", "2013-02-03"], ["2019-12-22 08:26:11"]]
            };
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).toBeNull()
        });

        it('Should not validate a wrong array of data types', () => {
            delete data.types;
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();

            data.types = ["this is not a valid data type", "sleepinghours"];
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();

            data.types = ["sleepinghours"]; //fails because the array is not as long as the array values
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate a wrong array of values', () => {
            delete data.values;
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();

            data.values = ["this is not a valid value", 4];
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();

            data.types = [5]; //fails because the array is not as long as the array timestamps
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate a wrong array of values', () => {
            delete data.timestamps;
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();

            data.timestamps = [["this is not a valid timestamp", "2012-02-14"]];
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();

            data.timestamps = [["2012-02-14", "2011-03-12"]]; //fails because the array is not as long as the array values
            result = Joi.validate(data, schemas["/data/upload"]);
            expect(result.error).not.toBeNull();
        })
    });


    describe('Retrieve the statistics for a private user', () => {

        it('Should validate a well formed schema', () => {
            result = Joi.validate({"types" : ["heartrate","sleepinghours"]}, schemas["/data/stats"]);
            expect(result.error).toBeNull()
        });
    });


    describe('Send a single request', () => {

        let request;

        beforeEach(() => {
            request = {
                "subscribing" : true,
                "fc" : "1234363913333333",
                "types" : ["heartrate"]
            }
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate(request, schemas["/req/tp/sendSingle"]);
            expect(result.error).toBeNull()
        });

        it('Should not validate a wrong subscribing value', () => {
            delete request.subscribing; //this is correct because default value is false
            result = Joi.validate(request, schemas["/req/tp/sendSingle"]);
            expect(result.error).toBeNull();

            request.subscribing = "not a boolean";
            result = Joi.validate(request, schemas["/req/tp/sendSingle"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate a wrong duration value', () => {
            delete request.duration; //this is correct because it can be missing
            result = Joi.validate(request, schemas["/req/tp/sendSingle"]);
            expect(result.error).toBeNull();

            request.duration = "not an integer";
            result = Joi.validate(request, schemas["/req/tp/sendSingle"]);
            expect(result.error).not.toBeNull();

            request.subscribing = false;
            request.duration = 5;
            result = Joi.validate(request, schemas["/req/tp/sendSingle"]);
            expect(result.error).not.toBeNull();
        });
    });


    describe('Send a group request', () => {

        let request;

        beforeEach(() => {
            request = {
                "subscribing" : true,
                "types" : ["heartrate"],
                "duration" : 25,
                "bounds" : [{
                    "lowerbound":22,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            }
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).toBeNull()
        });

        it('Should not validate a wrong array of parameters', () => {
            delete request.parameters;
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).not.toBeNull();

            request.parameters = ["this is not a valid datatype", "sleepinghours"];
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).not.toBeNull();

            request.parameters = ["sleepinghours","heartrate"]; //fails because the array is not as long as the array bounds
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate a wrong array of bounds', () => {
            delete request.bounds;
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).not.toBeNull();

            request.bounds = [{
                "lowerbound": "not a valid lowerbound",
                "upperbound":100
            }];
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).not.toBeNull();

            request.bounds = [{
                "upperbound":100
            }];
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]); //this is correct because bounds might be missing
            expect(result.error).toBeNull();

            request.bounds = []; //fails because the array is not as long as the array parameters
            result = Joi.validate(request, schemas["/req/tp/sendGroup"]);
            expect(result.error).not.toBeNull();
        });
    });


    describe('Choose to accept or refuse a request', () => {

        let request;

        beforeEach(() => {
            request = {
                "reqID" : "1",
                "choice" : true
            }
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate(request, schemas["/req/single/choice"]);
            expect(result.error).toBeNull()
        });

        it('Should not validate a wrong reqID', () => {
            delete request.reqID;
            result = Joi.validate(request, schemas["/req/single/choice"]);
            expect(result.error).not.toBeNull();

            request.reqID = "not an integer";
            result = Joi.validate(request, schemas["/req/single/choice"]);
            expect(result.error).not.toBeNull();
        });

        it('Should not validate a wrong choice', () => {
            delete request.choice;
            result = Joi.validate(request, schemas["/req/single/choice"]);
            expect(result.error).not.toBeNull();

            request.choice = "not a boolean";
            result = Joi.validate(request, schemas["/req/single/choice"]);
            expect(result.error).not.toBeNull();
        });
    });


    describe('Download content of a request', () => {

        it('Should validate a well formed schema', () => {
            result = Joi.validate({
                "reqID" : "1"
            }, schemas["/req/tp/downloadSingle"]);
            expect(result.error).toBeNull()
        });

        it('Should validate a well formed schema', () => {
            result = Joi.validate({
                "reqID" : "1"
            }, schemas["/req/tp/downloadGroup"]);
            expect(result.error).toBeNull()
        });
    });


});