const request = require('supertest');
const db = require('../../../utils/dbconnection');
let server;


//not testing login and if the user is a third party when sending a request, that check has already been tested
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
                "duration" : 25,
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
            expect(req.rows[0].duration).toBe(25);
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

});