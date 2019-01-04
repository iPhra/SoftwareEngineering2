//@todo bug date

const request = require('supertest');
const db = require('../../../utils/dbconnection');
let server;


describe('/data', () => {

    let authToken_pu;

    const privateuser = {
        "email" : "extreme_enigma@hotmail.it",
        "password" : "password",
        "fc" : "1234363912333133",
        "full_name" : "Francesco Lorenzo",
        "birthdate" : "1996-08-16",
        "sex" : "M"
    };

    //before each test, i register a private user, activate its accounts and log him in
    beforeEach(async () => {
        server = require('../../../bin/www');

        //register
        await request(server).post('/auth/reg/single').send(privateuser)
            .set('Content-Type', 'application/json')
            .set('Accept', 'application/json');

        //activate the account
        const token = (await db.query("SELECT activ_token FROM Registration")).rows[0].activ_token;
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


    describe('/upload', () => {

        it('should let a single user upload his data', async () => {
            const res = await request(server).post('/data/upload').send({
                "types" : ["heartrate","sleepinghours"],
                "values" : [[98, 7], [8]],
                "timestamps" : [["2008-12-22 08:26:12", "2013-02-03"], ["2019-12-22 08:26:11"]]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);

            expect(res.status).toBe(200);

            const data = await db.query("SELECT * FROM userdata WHERE userid=$1",[1]);
            expect(data.rows[0].datatype).toEqual("heartrate");
            expect(data.rows[0].timest.toISOString().slice(0,10)).toMatch("2008-12");
            expect(data.rows[0].value).toBe(98);

            expect(data.rows[1].datatype).toEqual("heartrate");
            expect(data.rows[1].timest.toISOString().slice(0,10)).toMatch("2013-02");
            expect(data.rows[1].value).toBe(7);

            expect(data.rows[2].datatype).toEqual("sleepinghours");
            expect(data.rows[2].timest.toISOString().slice(0,10)).toMatch("2019-12");
            expect(data.rows[2].value).toBe(8)
        });

        it('should forbid a non logged in user to upload his data settings', async () => {
            const res = await request(server).post('/data/upload').send({
                "types" : ["heartrate","sleepinghours"],
                "values" : [[98, 7], [8]],
                "timestamps" : [["2008-12-22 08:26:12", "2013-02-03"], ["2019-12-22 08:26:11"]]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', "00000"); //bad token

            expect(res.status).toBe(401);
        });

        it('should throw away already imported data', async () => {
            await request(server).post('/data/upload').send({
                "types" : ["heartrate","sleepinghours"],
                "values" : [[98, 7], [8]],
                "timestamps" : [["2008-12-22 08:26:12", "2013-02-03"], ["2019-12-22 08:26:11"]]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);

            const res = await request(server).post('/data/upload').send({
                "types" : ["sleepinghours", "heartrate"],
                "values" : [[7,8,10], []],
                "timestamps" : [["2010-01-18", "2019-12-22 08:26:11", "2002-02-02"], []]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);


            expect(res.status).toBe(200);

            const data = await db.query("SELECT * FROM userdata WHERE userid=$1",[1]);
            expect(data.rows[2].datatype).toEqual("sleepinghours");
            expect(data.rows[2].timest.toISOString().slice(0,10)).toMatch("2019-12");
            expect(data.rows[2].value).toBe(8);

            expect(data.rows[3].datatype).toEqual("sleepinghours");
            expect(data.rows[3].timest.toISOString().slice(0,10)).toMatch("2010-01");
            expect(data.rows[3].value).toBe(7);

            expect(data.rows[4].datatype).toEqual("sleepinghours");
            expect(data.rows[4].timest.toISOString().slice(0,10)).toMatch("2002-02");
            expect(data.rows[4].value).toBe(10);

            expect(data.rowCount).toBe(5); //only 5 rows, not 6, as one was already present
        })
    });


    describe('/data/stats', async () => {

        it('should let a single user retrieve statistics about his imported data', async () => {
            //upload data of the first user
            await request(server).post('/data/upload').send({
                "types" : ["heartrate","sleepinghours"],
                "values" : [[98, 7], [8]],
                "timestamps" : [["2008-12-22 08:26:12", "2013-02-03"], ["2019-12-22 08:26:11"]]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);

            //register a second user
            await request(server).post('/auth/reg/single').send({
                "email" : "test@hotmail.it",
                "password" : "password",
                "fc" : "1234363912333100",
                "full_name" : "test",
                "birthdate" : "1996-08-16",
                "sex" : "M"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');

            //activate the account of the second user
            const token = (await db.query("SELECT activ_token FROM Registration")).rows[1].activ_token;
            await request(server).get('/auth/activ').query({activToken: token});

            //login
            const authToken_pu2 = (await request(server).post('/auth/login').send({
                "email" : "test@hotmail.it",
                "password" : "password",
            })).body.authToken;

            //upload data of the second user
            await request(server).post('/data/upload').send({
                "types" : ["heartrate"],
                "values" : [[96, 9]],
                "timestamps" : [["2008-12-12 08:26:12", "2013-03-03"]]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu2);

            //retrieve statistics of the first user
            const res = await request(server).post('/data/stats').send({
                "types" : ["heartrate", "sleepinghours"]
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json')
                .set('x-authToken', authToken_pu);


            expect(res.status).toBe(200);

            expect(res.body.data[0]["type"]).toEqual("heartrate");
            expect(res.body.data[0]["observations"][0].avg).toBe(98);
            expect(res.body.data[0]["observations"][0].month).toBe(12);
            expect(res.body.data[0]["observations"][0].year).toBe(2008);

            expect(res.body.data[0]["observations"][1].avg).toBe(7);
            expect(res.body.data[0]["observations"][1].month).toBe(2);
            expect(res.body.data[0]["observations"][1].year).toBe(2013);

            //this is the average between the first user and second user on 12/2008
            expect(res.body.data[0]["others"][0].avg).toBe(97);
            expect(res.body.data[0]["observations"][0].month).toBe(12);
            expect(res.body.data[0]["observations"][0].year).toBe(2008);

            //the other data imported by the second user is in a different month so the average isn't changed
            expect(res.body.data[0]["others"][1].avg).toBe(7);
            expect(res.body.data[0]["observations"][1].month).toBe(2);
            expect(res.body.data[0]["observations"][1].year).toBe(2013);

            expect(res.body.data[1]["type"]).toEqual("sleepinghours");
            expect(res.body.data[1]["observations"][0].avg).toBe(8);
            expect(res.body.data[1]["observations"][0].month).toBe(12);
            expect(res.body.data[1]["observations"][0].year).toBe(2019);

            //only user in the db with sleepinghours, so the global average matches his average
            expect(res.body.data[1]["others"]).toMatchObject(res.body.data[1]["observations"]);
        });
    });

});