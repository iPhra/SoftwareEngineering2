const request = require('supertest');
let server;


describe('/auth', () => {

    beforeEach(() => { server = require('../../../bin/www') });

    afterEach(() => { server.close() });

    describe('/reg/single', () => {

        it('should let a single user register in the database', async () => {
            const res = await request(server).post('/auth/reg/single').send({
                "email" : "extreme_enigma@hotmail.it",
                "password" : "password",
                "fc" : "1234363912333133",
                "full_name" : "Francesco Lorenzo",
                "birthdate" : "1996-08-16",
                "sex" : "M"
            })
                .set('Content-Type', 'application/json')
                .set('Accept', 'application/json');
            expect(res.status).toBe(200);
        })
    })
});