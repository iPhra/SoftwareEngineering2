const request = require('supertest');
const db = require('../../../utils/dbconnection');
let server;


//not testing login and if the user is a third party when sending a request, that check has already been tested in auth.test.js
describe('/req', () => {

    let authToken_pu1;
    let authToken_pu2;
    let authToken_tp;

    const privateuser1 = {
        "email" : "extreme_enigma@hotmail.it",
        "password" : "password",
        "fc" : "1234363912333133",
        "full_name" : "Francesco Lorenzo",
        "birthdate" : "1996-08-16",
        "sex" : "M"
    };

    const privateuser2 = {
        "email" : "test@hotmail.it",
        "password" : "password",
        "fc" : "1234363912333100",
        "full_name" : "test",
        "birthdate" : "1994-02-12",
        "sex" : "F"
    };

    const thirdparty = {
        "email" : "thirdparty@gmail.com",
        "password" : "password",
        "piva" : "00000000000",
        "company_name" : "Third Party",
        "company_description" : "test"
    };

    //before each test, i register a third party user and a private user, activate their accounts and log them in
    beforeEach(async () => {
        server = require('../../../bin/www');

        //register
        await request(server).post('/auth/reg/tp').send(thirdparty)
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json');

        //activate the account
        let token = (await db.query("SELECT activ_token FROM Registration")).rows[0].activ_token;
        await request(server).get('/auth/activ').query({activToken: token});

        //login
        authToken_tp = (await request(server).post('/auth/login').send({
            "email" : "thirdparty@gmail.com",
            "password" : "password",
        })).body.authToken;

        //register
        await request(server).post('/auth/reg/single').send(privateuser1)
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json');

        //activate the account
        token = (await db.query("SELECT activ_token FROM Registration")).rows[1].activ_token;
        await request(server).get('/auth/activ').query({activToken: token});

        //login
        authToken_pu1 = (await request(server).post('/auth/login').send({
            "email" : "extreme_enigma@hotmail.it",
            "password" : "password",
        })).body.authToken;

        //register
        await request(server).post('/auth/reg/single').send(privateuser2)
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json');

        //activate the account
        token = (await db.query("SELECT activ_token FROM Registration")).rows[2].activ_token;
        await request(server).get('/auth/activ').query({activToken: token});

        //login
        authToken_pu2 = (await request(server).post('/auth/login').send({
            "email" : "test@hotmail.it",
            "password" : "password",
        })).body.authToken;

        //upload data of user 1
        await request(server).post('/data/upload').send({
            "types" : ["heartrate","sleepinghours"],
            "values" : [[98, 7], [8]],
            "timestamps" : [["2008-12-22 08:26:12", "2013-02-03"], ["2019-12-22 08:26:11"]]
        })
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json')
            .set('x-authToken', authToken_pu1);

        //upload data of user 2
        await request(server).post('/data/upload').send({
            "types" : ["heartrate", "stepcount"],
            "values" : [[96, 9], [180]],
            "timestamps" : [["2008-12-12 08:26:12", "2013-03-03"], ["2019-01-01 07:21:13"]]
        })
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json')
            .set('x-authToken', authToken_pu2);
    });

    //after each test suite, i close the server (otherwise port 3000 is still running when i import it) and drop all content in the db
    afterEach(async () => {
        server.close();
        await db.query("TRUNCATE grouprequest, singlerequest, privateuser, thirdparty, userdata, searchparameter, requestcontent, registration")
    });

    //close db
    afterAll(() => {
        db.pool.end();
    });


    describe('/tp/sendSingle', () => {

        it('should let a third party send a request to a private user', async () => {
            //send request
            const res = await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            const req = await db.query("SELECT * FROM singlerequest");
            expect(req.rows[0].req_id).toBe(1);
            expect(req.rows[0].sender_id).toBe("1");
            expect(req.rows[0].receiver_id).toBe("2");
            expect(req.rows[0].subscribing).toBeTruthy();
            expect(req.rows[0].status).toMatch("pending");
            expect(req.rows[0].duration).toBe(10);
            expect(req.rows[0].req_date.toDateString()).toMatch((new Date()).toDateString());

            const content = await db.query("SELECT * FROM requestcontent");
            expect(content.rows[0].req_id).toBe(1);
            expect(content.rows[0].datatype).toMatch("heartrate");
        });

        it('should forbid to send a request to a non existing user ', async () => {
            //send request
            const res = await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333131", //non existing fc
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });

        it('should forbid to send a request to if there\'s already a pending one', async () => {
            //send request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //send request again
            const res = await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });
    });


    describe('/tp/sendGroup', () => {

        it('should let a third party send a group request', async () => {
            //send request
            const res = await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : false,
                "types" : ["heartrate","stepcount"],
                "bounds" : [{
                    "lowerbound":22,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            const req = await db.query("SELECT * FROM grouprequest");
            expect(req.rows[0].req_id).toBe(1);
            expect(req.rows[0].sender_id).toBe("1");
            expect(req.rows[0].subscribing).toBeFalsy();
            expect(req.rows[0].status).toMatch("pending");
            expect(req.rows[0].duration).toBe(null);
            expect(req.rows[0].req_date.toISOString().slice(0,7)).toMatch((new Date()).toISOString().slice(0,7));

            const content = await db.query("SELECT * FROM requestcontent");
            expect(content.rows[0].req_id).toBe(1);
            expect(content.rows[0].datatype).toMatch("heartrate");
            expect(content.rows[1].req_id).toBe(1);
            expect(content.rows[1].datatype).toMatch("stepcount");

            const parameters = await db.query("SELECT * FROM searchparameter");
            expect(parameters.rows[0].req_id).toBe(1);
            expect(parameters.rows[0].datatype).toMatch("heartrate");
            expect(parameters.rows[0].lowerbound).toBe(22);
            expect(parameters.rows[0].upperbound).toBe(100);
        });
    });


    describe('/single/choice', () => {

        it('should let a private user accept a request', async () => {
            //send request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing": true,
                "fc": "1234363912333133",
                "types": ["heartrate"],
                "duration": 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            const res = await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);


            expect(res.status).toBe(200);

            const req = await db.query("SELECT * FROM singlerequest");
            expect(req.rows[0].status).toMatch("accepted");
        });

        it('should let a private user refuse a request', async () => {
            //send request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing": true,
                "fc": "1234363912333133",
                "types": ["heartrate"],
                "duration": 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //refuse the request
            const res = await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": false
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);


            expect(res.status).toBe(200);

            const req = await db.query("SELECT * FROM singlerequest");
            expect(req.rows[0].status).toMatch("refused");
        });

        it('should not let a private user accept a non pending request', async () => {
            //send request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing": true,
                "fc": "1234363912333133",
                "types": ["heartrate"],
                "duration": 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //accept the request
            const res = await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);


            expect(res.status).toBe(403);

            const req = await db.query("SELECT * FROM singlerequest");
            expect(req.rows[0].status).toMatch("accepted");
        });

        it('should not let a private user accept a non existing request', async () => {
            //try to accept the request
            const res = await request(server).post('/req/single/choice').send({
                "reqID": "1", //non existing
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);


            expect(res.status).toBe(403);
        });
    });


    describe('/single/list', () => {

        it('should let a private user retrieve the list of its requests', async () => {
            //send first request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //send second request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : false,
                "email" : "extreme_enigma@hotmail.it",
                "types" : ["stepcount","activeenergyburned"],
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //retrieve list
            const res = await request(server).get('/req/single/list')
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);


            expect(res.status).toBe(200);

            expect(res.body.requests[0].reqid).toBe(1);
            expect(res.body.requests[0].email).toMatch("thirdparty@gmail.com");
            expect(res.body.requests[0].piva).toMatch("00000000000");
            expect(res.body.requests[0].company_name).toMatch("Third Party");
            expect(res.body.requests[0].types[0].datatype).toMatch("heartrate");
            expect(res.body.requests[0].status).toMatch("accepted");
            expect(res.body.requests[0].subscribing).toBeTruthy();
            expect(res.body.requests[0].duration).toBe(10);
            expect((new Date(res.body.requests[0].req_date)).toDateString()).toMatch((new Date()).toDateString());
            expect(res.body.requests[0].expired).toBeFalsy();

            expect(res.body.requests[1].reqid).toBe(2);
            expect(res.body.requests[1].email).toMatch("thirdparty@gmail.com");
            expect(res.body.requests[1].piva).toMatch("00000000000");
            expect(res.body.requests[1].company_name).toMatch("Third Party");
            expect(res.body.requests[1].types[0].datatype).toMatch("stepcount");
            expect(res.body.requests[1].types[1].datatype).toMatch("activeenergyburned");
            expect(res.body.requests[1].status).toMatch("pending");
            expect(res.body.requests[1].subscribing).toBeFalsy();
            expect(res.body.requests[1].duration).toBe(null);
            expect((new Date(res.body.requests[1].req_date)).toDateString()).toMatch((new Date()).toDateString());
            expect(res.body.requests[1].expired).toBeTruthy();

        });
    });


    describe('/group/list', () => {

        it('should let a third party retrieve the list of its requests', async () => {
            //send first request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //send second request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : false,
                "email" : "test@hotmail.it",
                "types" : ["stepcount","activeenergyburned"],
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //send group request
            await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : true,
                "types" : ["heartrate","stepcount"],
                "bounds" : [{
                    "lowerbound":22,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //retrieve list
            const res = await request(server).get('/req/tp/list')
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            expect(res.body.requests.single[0].reqid).toBe(1);
            expect(res.body.requests.single[0].email).toMatch("extreme_enigma@hotmail.it");
            expect(res.body.requests.single[0].fc).toMatch("1234363912333133");
            expect(res.body.requests.single[0].full_name).toMatch("Francesco Lorenzo");
            expect(res.body.requests.single[0].types[0].datatype).toMatch("heartrate");
            expect(res.body.requests.single[0].status).toMatch("pending");
            expect(res.body.requests.single[0].subscribing).toBeTruthy();
            expect(res.body.requests.single[0].duration).toBe(10);
            expect((new Date(res.body.requests.single[0].req_date)).toDateString()).toMatch((new Date()).toDateString());
            expect(res.body.requests.single[0].expired).toBeFalsy();

            expect(res.body.requests.single[1].reqid).toBe(2);
            expect(res.body.requests.single[1].email).toMatch("test@hotmail.it");
            expect(res.body.requests.single[1].fc).toMatch("1234363912333100");
            expect(res.body.requests.single[1].full_name).toMatch("test");
            expect(res.body.requests.single[1].types[0].datatype).toMatch("stepcount");
            expect(res.body.requests.single[1].types[1].datatype).toMatch("activeenergyburned");
            expect(res.body.requests.single[1].status).toMatch("pending");
            expect(res.body.requests.single[1].subscribing).toBeFalsy();
            expect(res.body.requests.single[1].duration).toBe(null);
            expect((new Date(res.body.requests.single[1].req_date)).toDateString()).toMatch((new Date()).toDateString());
            expect(res.body.requests.single[1].expired).toBeTruthy();

            expect(res.body.requests.group[0].reqid).toBe(3);
            expect(res.body.requests.group[0].types[0].datatype).toMatch("heartrate");
            expect(res.body.requests.group[0].types[1].datatype).toMatch("stepcount");
            expect(res.body.requests.group[0].parameters[0].lowerbound).toBe(22);
            expect(res.body.requests.group[0].parameters[0].upperbound).toBe(100);
            expect(res.body.requests.group[0].status).toMatch("pending");
            expect(res.body.requests.group[0].subscribing).toBeTruthy();
            expect(res.body.requests.group[0].duration).toBe(1);
            expect((new Date(res.body.requests.group[0].req_date)).toDateString()).toMatch((new Date()).toDateString());
            expect(res.body.requests.group[0].expired).toBeFalsy();
        });
    });


    describe('/sub/endSingle', () => {

        it('should let a private user end a subscription', async () => {
            //send a request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //retrieve list
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);


            expect(res.status).toBe(200);

            const sub = await db.query("SELECT * FROM singlerequest");
            expect(sub.rows[0].subscribing).toBeFalsy()
        });

        it('should let a third party end a subscription', async () => {
            //send a request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //end the sub
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            const sub = await db.query("SELECT * FROM singlerequest");
            expect(sub.rows[0].subscribing).toBeFalsy()
        });


        it('should not let a user end a subscription that was already false', async () => {
            //send a request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : false,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //try to end it
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });


        it('should not let a user end a subscription that wasn\'t accepted', async () => {
            //send a request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : false,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //try to end it
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });


        it('should not let a user end a subscription that doesn\'t belong to him', async () => {
            //send a request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : false,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //try to end it
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu2); //he can't stop the sub


            expect(res.status).toBe(403);
        });
    });


    describe('/sub/endGroup', () => {

        it('should let a third party end a subscription', async () => {
            //send a request
            await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : true,
                "types" : ["heartrate","stepcount"],
                "bounds" : [{
                    "lowerbound":22,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //download the result to accept it
            await request(server).post('/req/tp/downloadGroup').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //end the sub
            const res = await request(server).post('/req/sub/endGroup').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            const sub = await db.query("SELECT * FROM grouprequest");
            expect(sub.rows[0].subscribing).toBeFalsy()
        });


        it('should not let a user end a subscription that was already false', async () => {
            //send a request
            await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : false,
                "types" : ["heartrate","stepcount"],
                "bounds" : [{
                    "lowerbound":22,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //download the result to accept it
            await request(server).post('/req/tp/downloadGroup').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //try to end it
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });


        it('should not let a user end a subscription that wasn\'t accepted', async () => {
            //send a request
            await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : false,
                "types" : ["heartrate","stepcount"],
                "bounds" : [{
                    "lowerbound":22,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //try to end it
            const res = await request(server).post('/req/sub/endSingle').send({
                "reqID": "1",
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });
    });


    describe('/tp/downloadSingle', () => {

        it('should let a third party download the results of an accepted request', async () => {
            //send request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //accept the request
            await request(server).post('/req/single/choice').send({
                "reqID": "1",
                "choice": true
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu1);

            //download the result
            const res = await request(server).post('/req/tp/downloadSingle').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            expect(res.body.data[0].type).toMatch("heartrate");
            expect(res.body.data[0].observations[0].value).toBe(98);
            expect(new Date(res.body.data[0].observations[0].timest).toISOString().slice(0,10)).toMatch("2008-12-22"); //in order of date

            expect(res.body.data[0].observations[1].value).toBe(7);
            expect(new Date(res.body.data[0].observations[1].timest).toISOString().slice(0,10)).toMatch("2013-02-02");
        });

        it('should not let a third party download the results of a non accepted request', async () => {
            //send request
            await request(server).post('/req/tp/sendSingle').send({
                "subscribing" : true,
                "fc" : "1234363912333133",
                "types" : ["heartrate"],
                "duration" : 10
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //download the result
            const res = await request(server).post('/req/tp/downloadSingle').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });

        it('should not let a third party download the results of a request that doesn\'t exist', async () => {
            //download the result
            const res = await request(server).post('/req/tp/downloadSingle').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });
    });


    describe('/tp/downloadGroup', () => {

        it('should let a third party download the results of a group request', async () => {
            //send request
            await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : false,
                "types" : ["heartrate"],
                "bounds" : [{
                    "lowerbound":0,
                    "upperbound":100
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //download the result
            const res = await request(server).post('/req/tp/downloadGroup').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            const req = await db.query("SELECT * FROM grouprequest");
            expect(req.rows[0].status).toMatch("accepted");

            expect(res.body.data[0].userid).toBe(0);
            expect(res.body.data[0].data[0].type).toMatch("heartrate");
            expect(res.body.data[0].data[0].values[0].value).toBe(98);
            expect(new Date(res.body.data[0].data[0].values[0].timest).toISOString().slice(0,10)).toMatch("2008-12-22"); //in order of date

            expect(res.body.data[0].data[0].values[1].value).toBe(7);
            expect(new Date(res.body.data[0].data[0].values[1].timest).toISOString().slice(0,10)).toMatch("2013-02-02");

            expect(res.body.data[1].userid).toBe(1);
            expect(res.body.data[1].data[0].type).toMatch("heartrate");
            expect(res.body.data[1].data[0].values[0].value).toBe(96);
            expect(new Date(res.body.data[1].data[0].values[0].timest).toISOString().slice(0,10)).toMatch("2008-12-12"); //in order of date

            expect(res.body.data[1].data[0].values[1].value).toBe(9);
            expect(new Date(res.body.data[1].data[0].values[1].timest).toISOString().slice(0,10)).toMatch("2013-03-02");
        });

        it('should not let a third party download the results of a request that doesn\'t exist', async () => {
            //download the result
            const res = await request(server).post('/req/tp/downloadGroup').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });

        it('should not let a third party download the results of a request that doesn\'t match the parameter constraint', async () => {
            //send request
            await request(server).post('/req/tp/sendGroup').send({
                "subscribing" : false,
                "types" : ["heartrate"],
                "bounds" : [{
                    "lowerbound":0,
                    "upperbound":5
                }],
                "parameters" : ["heartrate"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);

            //download the result
            const res = await request(server).post('/req/tp/downloadGroup').send({
                "reqID": "1"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(403);
        });
    });

});