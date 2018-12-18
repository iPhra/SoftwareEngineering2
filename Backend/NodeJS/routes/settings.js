const Router = require('express-promise-router');
const db = require('../settings/dbconnection');
const utils = require('./utils');
const authenticator = require('../middlewares/authenticator');

const hashPassword = utils.hashPassword;
const logError = utils.logError;
const router = new Router();


router.post('/single/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="PrivateUser")
            return res.status(401).send({error: "You need to login with a Single User account"});


        await(db.query('BEGIN'));

        let text;
        let values;

        if(req.body.password) {
            const password = await(hashPassword(req.body.password));
            text = "UPDATE PrivateUser SET password=$1 WHERE userID=$2";
            values = [password, userID];
            await db.query(text, values);
        }

        if(req.body.full_name) {
            text = "UPDATE PrivateUser SET full_name=$1 WHERE userID=$2";
            values = [req.body.full_name, userID];
            await db.query(text, values);
        }

        if(req.body.birthdate) {
            text = "UPDATE PrivateUser SET birthdate=$1 WHERE userID=$2";
            values = [req.body.birthdate, userID];
            await db.query(text, values);
        }

        await(db.query('COMMIT'));
        res.status(200).send({message: "Settings updated"});
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }
});


router.post('/tp/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="ThirdParty")
            return res.status(401).send({error: "You need to login with a Third Party account"});

        await(db.query('BEGIN'));

        let text;
        let values;

        if(req.body.password) {
            const password = await(hashPassword(req.body.password));
            text = "UPDATE ThirdParty SET password=$1 WHERE userID=$2";
            values = [password, userID];
            await db.query(text, values);
        }

        if(req.body.company_name) {
            text = "UPDATE ThirdParty SET company_name=$1 WHERE userID=$2";
            values = [req.body.company_name, userID];
            await db.query(text, values);
        }

        if(req.body.company_description) {
            text = "UPDATE ThirdParty SET company_description=$1 WHERE userID=$2";
            values = [req.body.company_description, userID];
            await db.query(text, values);
        }

        await(db.query('COMMIT'));
        res.status(200).send({message: "Settings updated"});
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }
});


router.post('/single/data', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not logged in or he's not a PrivateUser
        if (req.body.usertype!=="PrivateUser")
            return res.status(401).send({error: "You need to login with a Single User account"});

        await(db.query('BEGIN'));

        let text;
        let values;
        let rows;

        //for each value i'm trying to insert
        for(let i=0; i<req.body.types.length; i++) {

            text = "SELECT * FROM usersettings WHERE userid=$1 and datatype=$2";
            values = [userID, req.body.types[i]];
            rows = await db.query(text, values);

            //if the datatype is already present in the database, i just update the column 'enabled'
            if(rows.rowCount>0) {
                text = "UPDATE usersettings SET enabled=$1 WHERE userid=$2 AND datatype=$3";
                values = [req.body.enabled[i], userID, req.body.types[i]];
                await db.query(text, values)
            }

            //if it is not present, i insert the whole tuple
            else {
                text = "INSERT INTO usersettings VALUES($1, $2, $3)";
                values = [userID, req.body.types[i], req.body.enabled[i]];
                await db.query(text, values)
            }
        }

        await(db.query('COMMIT'));
        res.status(200).send({message: "Settings updated"});
    } catch(error) {
        await(db.query('ROLLBACK'));
        return logError(error, res)
    }
});


router.get('/tp/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not a PrivateUser
        if (req.body.usertype!=="ThirdParty")
            return res.status(401).send({error: "You need to login with a Third Party account"});

        //get all the requests addressing the user
        const text = 'SELECT email, company_name, piva, company_description FROM thirdparty WHERE userid = $1';
        const values = [userID];
        const settings = await db.query(text, values);

        res.status(200).send({settings: {
                email: settings.rows[0].email,
                piva: settings.rows[0].piva,
                company_name: settings.rows[0].company_name,
                company_description: settings.rows[0].company_description
            }});
    } catch(error) {
        return logError(error, res)
    }
});


router.get('/single/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    try {

        //if he's not a PrivateUser
        if (req.body.usertype!=="PrivateUser")
            return res.status(401).send({error: "You need to login with a Single User account"});

        //get all the requests addressing the user
        const text = 'SELECT email, full_name, fc, birthdate FROM privateuser WHERE userid = $1';
        const values = [userID];
        const settings = await db.query(text, values);

        res.status(200).send({settings: {
            email: settings.rows[0].email,
                fc: settings.rows[0].fc,
                full_name: settings.rows[0].full_name,
                birthdate: (settings.rows[0].birthdate).toISOString().slice(0,10)
            }});
    } catch(error) {
        return logError(error, res)
    }
});


module.exports = router;