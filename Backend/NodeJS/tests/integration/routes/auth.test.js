const jwt = require('jsonwebtoken');
const config = require('config');
const request = require('supertest');
const db = require('../../../utils/dbconnection');
const bcrypt = require('bcryptjs');
let server;


describe('/auth', () => {

    //i start the server every time i run a test suite
    beforeEach(() => { server = require('../../../bin/www') });

    //after each test suite, i close the server (otherwise port 3000 is still running when i import it) and drop all content in the db
    afterEach(async () => {
        server.close();
        await db.query("TRUNCATE grouprequest, singlerequest, privateuser, thirdparty, userdata, searchparameter, requestcontent, registration")
    });

    //close db
    afterAll(() => {
        db.pool.end();
    });


    describe('/reg/single', () => {

        const privateuser = {
            "email" : "extreme_enigma@hotmail.it",
            "password" : "password",
            "fc" : "1234363912333133",
            "full_name" : "Francesco Lorenzo",
            "birthdate" : "1996-08-16",
            "sex" : "M"
        };

        it('should let a single user register in the database', async () => {
            //register the user
            const res = await request(server).post('/auth/reg/single').send(privateuser)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');


            expect(res.status).toBe(200);

            const reg = await db.query("SELECT * FROM Registration");
            const dbuser = await db.query("SELECT * FROM PrivateUser");
            expect(reg.rows[0].activated).toBeFalsy(); //account can't be activated yet
            expect(dbuser.rows[0].email).toEqual(privateuser.email);
            expect(await bcrypt.compare(dbuser.rows[0].password, privateuser.password));
            expect(dbuser.rows[0].fc).toEqual(privateuser.fc);
            expect(dbuser.rows[0].full_name).toEqual(privateuser.full_name);
            expect((new Date(dbuser.rows[0].birthdate)).toDateString()).toEqual((new Date(privateuser.birthdate)).toDateString());
            expect(dbuser.rows[0].sex).toEqual(privateuser.sex);
        });

        it('should forbid an already registered user to register again', async () => {
            //insert the user the first time
            await request(server).post('/auth/reg/single').send(privateuser)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //try to register the user again
            const error = await request(server).post('/auth/reg/single').send(privateuser)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');


            expect(error.status).toBe(403);
        })
    });


    describe('/reg/tp', () => {

        const thirdparty = {
            "email" : "thirdparty@gmail.com",
            "password" : "password",
            "piva" : "00000000000",
            "company_name" : "Third Party",
            "company_description" : "test"
        };

        it('should let a third party register in the database', async () => {
            //register the user
            const res = await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            expect(res.status).toBe(200);

            const reg = await db.query("SELECT * FROM Registration");
            const dbuser = await db.query("SELECT * FROM ThirdParty");
            expect(reg.rows[0].activated=false); //account can't be activated yet
            expect(dbuser.rows[0].email).toEqual(thirdparty.email);
            expect(await bcrypt.compare(dbuser.rows[0].password, thirdparty.password));
            expect(dbuser.rows[0].piva).toEqual(thirdparty.piva);
            expect(dbuser.rows[0].company_name).toEqual(thirdparty.company_name);
            expect(dbuser.rows[0].company_description).toEqual(thirdparty.company_description);
        });

        it('should forbid an already registered user to register again', async () => {
            //insert the user the first time
            await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //try to register the user again
            const error = await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');


            expect(error.status).toBe(403);
        })
    });


    describe('/activ', () => {

        const thirdparty = {
            "email" : "thirdparty@gmail.com",
            "password" : "password",
            "piva" : "00000000000",
            "company_name" : "Third Party",
            "company_description" : "test"
        };

        it('should let a third party activate his registered account', async () => {
            //register the user
            await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //get the generated token from the database to be used for activation
            const token = (await db.query("SELECT activ_token FROM Registration")).rows[0].activ_token;

            //activate the account
            const res = await request(server).get('/auth/activ').query({activToken: token});


            expect(res.status).toBe(200);

            const activated = await db.query("SELECT activated FROM Registration");
            expect(activated.rows[0].activated).toBeTruthy(); //account can't be activated yet
        });

        it('should not let a third party re-activated his account', async () => {
            //register the user
            await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //get the token
            const token = (await db.query("SELECT activ_token FROM Registration")).rows[0].activ_token;

            //activate the account
            await request(server).get('/auth/activ').query({activToken: token});

            //try to reactivate the account again
            const res = await request(server).get('/auth/activ').query({activToken: token});


            expect(res.status).toBe(403);
        });

        it('should not let a third party activate a non existing account', async () => {
            //activate a non existing account
            const res = await request(server).get('/auth/activ').query({activToken: "faketoken"});


            expect(res.status).toBe(401);
        });
    });


    describe('/login', () => {

        const thirdparty = {
            "email" : "thirdparty@gmail.com",
            "password" : "password",
            "piva" : "00000000000",
            "company_name" : "Third Party",
            "company_description" : "boh"
        };

        it('should let a registered user login in the service', async () => {
            //register the account
            await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //get the token
            const token = (await db.query("SELECT activ_token FROM Registration")).rows[0].activ_token;

            //activate the account
            await request(server).get('/auth/activ').query({activToken: token});

            //login
            const res = await request(server).post('/auth/login').send({
                "email" : "thirdparty@gmail.com",
                "password" : "password",
            });


            expect(res.status).toBe(200);

            const decoded = await jwt.verify(res.body.authToken, config.get('jwtPrivateKey'));
            expect(decoded.userid).toBe("1");
            expect(decoded.usertype).toBe("ThirdParty");
        });

        it('should forbid a user to login if the account does not exist', async () => {
            //login
            const res = await request(server).post('/auth/login').send({
                "email" : "thirdparty@gmail.com",
                "password" : "password",
            });


            expect(res.status).toBe(401);
        });

        it('should forbid a user to login if the account is not activated', async () => {
            //register
            await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //login
            const res = await request(server).post('/auth/login').send({
                "email" : "thirdparty@gmail.com",
                "password" : "password",
            });


            expect(res.status).toBe(401);

            const activated = (await db.query("SELECT activated FROM Registration")).rows[0].activated;
            expect(activated).toBeFalsy()
        });

        it('should forbid a user to login if the passsword is wrong', async () => {
            //register
            await request(server).post('/auth/reg/tp').send(thirdparty)
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //get the token
            const token = (await db.query("SELECT activ_token FROM Registration")).rows[0].activ_token;

            //activate the account
            await request(server).get('/auth/activ').query({activToken: token});

            //login
            const res = await request(server).post('/auth/login').send({
                "email" : "thirdparty@gmail.com",
                "password" : "wrongpassword",
            });


            expect(res.status).toBe(401);
        });
    });

});