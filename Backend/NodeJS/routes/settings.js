const Router = require('express-promise-router');
const db = require('../utils/dbconnection');
const utils = require('../utils/utils');
const authenticator = require('../middlewares/authenticator');

const addDays = utils.addDays;
const hashPassword = utils.hashPassword;
const router = new Router();


//change the settings for a PrivateUser
router.post('/single/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

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
});


//change the settings for a ThirdParty
router.post('/tp/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    //if he's not logged in or he's not a ThirdParty
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
});


//retrieve the settings for a ThirdParty
router.get('/tp/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

    //if he's not a ThirdParty
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
});


//retrieve the settings for a PrivateUser
router.get('/single/info', authenticator(), async (req, res) => {
    let userID = req.body.userid;

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
            birthdate: addDays((settings.rows[0].birthdate).toISOString().slice(0,10),1).toISOString().slice(0,10)
    }});
});



module.exports = router;