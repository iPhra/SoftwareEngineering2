const request = require('supertest');
const bcrypt = require('bcryptjs');
const db = require('../../../utils/dbconnection');
let server;


describe('/settings', () => {

    let authToken_pu;
    let authToken_tp;

    const privateuser = {
        "email" : "extreme_enigma@hotmail.it",
        "password" : "password",
        "fc" : "1234363912333133",
        "full_name" : "Francesco Lorenzo",
        "birthdate" : "1996-08-16",
        "sex" : "M"
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
        await request(server).post('/auth/reg/single').send(privateuser)
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json');

        //activate the account
        token = (await db.query("SELECT activ_token FROM Registration")).rows[1].activ_token;
        await request(server).get('/auth/activ').query({activToken: token});

        //login
        authToken_pu = (await request(server).post('/auth/login').send({
            "email" : "extreme_enigma@hotmail.it",
            "password" : "password",
        })).body.authToken;
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


    describe('/single/info', () => {

        it('should let a single user update his private settings', async () => {
            //change settings
            const res = await request(server).post('/settings/single/info').send({
                "password" : "newpassword",
                "full_name" : "Francesco Vito Lorenzo"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);


            expect(res.status).toBe(200);

            const settings = await db.query("SELECT * FROM privateuser WHERE userid=$1",[2]);
            expect(settings.rows[0].fc).toEqual(privateuser.fc); //same fc
            expect(settings.rows[0].full_name).toEqual("Francesco Vito Lorenzo"); //new full name
            expect(settings.rows[0].email).toEqual(privateuser.email); //same email
            expect(await bcrypt.compare(settings.rows[0].password, privateuser.password)).toBeFalsy(); //password is changed
            expect((new Date(settings.rows[0].birthdate)).toDateString()).toEqual((new Date(privateuser.birthdate)).toDateString());
        });

        it('should let a single user retrieve his private settings', async () => {
            //get settings
            const res = await request(server).get('/settings/single/info')
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);


            expect(res.status).toBe(200);

            expect(res.body.settings.fc).toEqual(privateuser.fc);
            expect(res.body.settings.email).toEqual(privateuser.email);
            expect(res.body.settings.full_name).toEqual(privateuser.full_name);
            console.log(res.body.settings.birthdate);
            expect((new Date(res.body.settings.birthdate)).toDateString()).toEqual((new Date(privateuser.birthdate)).toDateString());
        });

        it('should forbid a non logged in user to update his private settings', async () => {
            //change settings
            const res = await request(server).post('/settings/single/info').send({
                "password" : "newpassword",
                "full_name" : "Francesco Vito Lorenzo"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', "00000"); //bad token


            expect(res.status).toBe(401);
        });

        it('should forbid a third party user to update the settings of a private user', async () => {
            //change settings
            const res = await request(server).post('/settings/single/info').send({
                "password" : "newpassword",
                "full_name" : "Francesco Vito Lorenzo"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp); //logging in with a third party account


            expect(res.status).toBe(401);
        });
    });


    describe('/tp/info', () => {

        it('should let a third party update his private settings', async () => {
            //change settings
            const res = await request(server).post('/settings/tp/info').send({
                "password" : "newpassword",
                "company_name" : "Gruosso"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            const settings = await db.query("SELECT * FROM thirdparty WHERE userid=$1",[1]);
            expect(settings.rows[0].piva).toEqual(thirdparty.piva); //piva is the same
            expect(settings.rows[0].company_name).toEqual("Gruosso"); //new company name is Gruosso
            expect(settings.rows[0].company_description).toEqual(thirdparty.company_description); //company description was not changed
            expect(settings.rows[0].email).toEqual(thirdparty.email); //email is the same
            expect(await bcrypt.compare(settings.rows[0].password, thirdparty.password)).toBeFalsy() //password is changed
        });

        it('should let a third party retrieve his private settings', async () => {
            //get settings
            const res = await request(server).get('/settings/tp/info')
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_tp);


            expect(res.status).toBe(200);

            expect(res.body.settings.piva).toEqual(thirdparty.piva);
            expect(res.body.settings.email).toEqual(thirdparty.email);
            expect(res.body.settings.company_description).toEqual(thirdparty.company_description);
            expect(res.body.settings.company_name).toEqual(thirdparty.company_name);
        });

        it('should forbid a non logged in user to update his private settings', async () => {
            //change settings
            const res = await request(server).post('/settings/tp/info').send({
                "password" : "newpassword",
                "company_name" : "Gruosso"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', "00000"); //bad token


            expect(res.status).toBe(401);
        });

        it('should forbid a private user to update the settings of a third party', async () => {
            //change settings
            const res = await request(server).post('/settings/tp/info').send({
                "password" : "newpassword",
                "company_name" : "Gruosso"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu); //logging in with a private user account


            expect(res.status).toBe(401);
        });
    });

});